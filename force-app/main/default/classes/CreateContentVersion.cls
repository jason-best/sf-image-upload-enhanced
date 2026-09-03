/**
 * Flow invocable: creates a ContentVersion from base64 data.
 * Use with Image Upload Enhanced (map imageData64 / fileName / parent record Id).
 */
public without sharing class CreateContentVersion {
    public class SaveContentVersionRequest {
        @InvocableVariable(required=true label='File Base64')
        public String fileBase64;
        @InvocableVariable(required=true label='File Name')
        public String fileName;
        @InvocableVariable(required=true label='Parent Record Id')
        public Id parentId;
        @InvocableVariable(required=false label='Owner Id')
        public String ownerId;
    }

    public class FlowOutput {
        @InvocableVariable(label='Status')
        public String status;
        @InvocableVariable(label='File Size')
        public Integer fileSize;
        @InvocableVariable(label='Content Version Id')
        public Id contentVersionId;
    }

    @InvocableMethod(
        label='Save Content Version'
        description='Creates a ContentVersion record from base64 data'
    )
    public static List<FlowOutput> saveContentVersion(List<SaveContentVersionRequest> requests) {
        List<FlowOutput> outputs = new List<FlowOutput>();
        for (SaveContentVersionRequest request : requests) {
            FlowOutput output = new FlowOutput();
            try {
                String fileBase64 = request.fileBase64;
                if (fileBase64 != null && fileBase64.startsWith('data:')) {
                    Integer commaIdx = fileBase64.indexOf(',');
                    if (commaIdx > 0) {
                        fileBase64 = fileBase64.substring(commaIdx + 1);
                    }
                }

                if (String.isBlank(fileBase64)) {
                    throw new AuraHandledException('Empty base64 string');
                }
                if (String.isBlank(request.fileName)) {
                    throw new AuraHandledException('File name is required');
                }

                // Chunked validation — avoids regex limits on large payloads
                String validChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
                Integer chunkSize = 1000;
                for (Integer i = 0; i < fileBase64.length(); i += chunkSize) {
                    Integer endIndex = Math.min(i + chunkSize, fileBase64.length());
                    String chunk = fileBase64.substring(i, endIndex);
                    for (Integer j = 0; j < chunk.length(); j++) {
                        if (!validChars.contains(chunk.substring(j, j + 1))) {
                            throw new AuraHandledException('Invalid base64 string: contains invalid characters');
                        }
                    }
                }

                Integer paddingCount = 0;
                for (Integer i = fileBase64.length() - 1; i >= 0; i--) {
                    if (fileBase64.substring(i, i + 1) == '=') {
                        paddingCount++;
                    } else {
                        break;
                    }
                }
                if (paddingCount > 2) {
                    throw new AuraHandledException('Invalid base64 string: too many padding characters');
                }

                Blob fileData = EncodingUtil.base64Decode(fileBase64);

                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = request.fileName;
                contentVersion.PathOnClient = request.fileName;
                contentVersion.VersionData = fileData;
                contentVersion.IsMajorVersion = true;
                contentVersion.OwnerId = String.isNotBlank(request.ownerId)
                    ? request.ownerId
                    : UserInfo.getUserId();
                contentVersion.FirstPublishLocationId = request.parentId;

                insert contentVersion;

                output.status = 'Success';
                output.fileSize = fileData.size();
                output.contentVersionId = contentVersion.Id;
            } catch (Exception e) {
                output.status = 'Error: ' + e.getMessage();
                output.fileSize = 0;
                output.contentVersionId = null;
            }
            outputs.add(output);
        }
        return outputs;
    }
}
