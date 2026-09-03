@isTest
private class CreateContentVersionTest {

    private static final String TEST_FILE_BASE64 =
        EncodingUtil.base64Encode(Blob.valueOf('This is a test file content'));

    private static Account createTestAccount() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        return testAccount;
    }

    private static CreateContentVersion.SaveContentVersionRequest buildRequest(
        String fileBase64,
        String fileName,
        Id parentId,
        String ownerId
    ) {
        CreateContentVersion.SaveContentVersionRequest request =
            new CreateContentVersion.SaveContentVersionRequest();
        request.fileBase64 = fileBase64;
        request.fileName = fileName;
        request.parentId = parentId;
        request.ownerId = ownerId;
        return request;
    }

    @isTest
    static void testSaveContentVersionSuccess() {
        String testFileName = 'test_document.txt';
        Id testParentId = createTestAccount().Id;

        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest(TEST_FILE_BASE64, testFileName, testParentId, UserInfo.getUserId())
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals('Success', results[0].status, 'Status should be Success');
        System.assertNotEquals(null, results[0].contentVersionId, 'ContentVersionId should not be null');
        System.assert(results[0].fileSize > 0, 'File size should be greater than 0');

        ContentVersion cv = [
            SELECT Id, Title, PathOnClient, FirstPublishLocationId, OwnerId
            FROM ContentVersion
            WHERE Id = :results[0].contentVersionId
        ];
        System.assertEquals(testFileName, cv.Title);
        System.assertEquals(testFileName, cv.PathOnClient);
        System.assertEquals(testParentId, cv.FirstPublishLocationId);
        System.assertEquals(UserInfo.getUserId(), cv.OwnerId);
    }

    @isTest
    static void testSaveContentVersionWithDifferentOwner() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
        );
        insert testUser;

        String testFileName = 'test_document.txt';
        Id testParentId = createTestAccount().Id;

        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest(TEST_FILE_BASE64, testFileName, testParentId, testUser.Id)
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('Success', results[0].status);

        ContentVersion cv = [
            SELECT Id, OwnerId FROM ContentVersion WHERE Id = :results[0].contentVersionId
        ];
        System.assertEquals(testUser.Id, cv.OwnerId);
    }

    @isTest
    static void testSaveContentVersionWithInvalidBase64() {
        Id testParentId = createTestAccount().Id;
        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest('This is not a valid base64 string!@#$%^&*()', 'test_document.txt', testParentId, null)
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].status.startsWith('Error:'), 'Status should indicate an error');
        System.assertEquals(null, results[0].contentVersionId);
        System.assertEquals(0, results[0].fileSize);
    }

    @isTest
    static void testSaveContentVersionWithBase64Prefix() {
        String testFileName = 'test_document_with_prefix.txt';
        String base64WithPrefix = 'data:text/plain;base64,' + TEST_FILE_BASE64;
        Id testParentId = createTestAccount().Id;

        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest(base64WithPrefix, testFileName, testParentId, null)
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('Success', results[0].status);
        System.assertNotEquals(null, results[0].contentVersionId);

        ContentVersion cv = [
            SELECT Id, Title FROM ContentVersion WHERE Id = :results[0].contentVersionId
        ];
        System.assertEquals(testFileName, cv.Title);
    }

    @isTest
    static void testSaveContentVersionEmptyBase64() {
        Id testParentId = createTestAccount().Id;
        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest('', 'empty.txt', testParentId, null)
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].status.startsWith('Error:'));
        System.assertEquals(null, results[0].contentVersionId);
    }

    @isTest
    static void testSaveContentVersionMultipleRequests() {
        Id testParentId = createTestAccount().Id;
        List<CreateContentVersion.SaveContentVersionRequest> requests =
            new List<CreateContentVersion.SaveContentVersionRequest>{
                buildRequest(TEST_FILE_BASE64, 'test_document_1.txt', testParentId, null),
                buildRequest(TEST_FILE_BASE64, 'test_document_2.txt', testParentId, null)
            };

        Test.startTest();
        List<CreateContentVersion.FlowOutput> results =
            CreateContentVersion.saveContentVersion(requests);
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals('Success', results[0].status);
        System.assertEquals('Success', results[1].status);

        List<ContentVersion> cvs = [
            SELECT Id, Title
            FROM ContentVersion
            WHERE Id IN (:results[0].contentVersionId, :results[1].contentVersionId)
        ];
        System.assertEquals(2, cvs.size());
    }
}
