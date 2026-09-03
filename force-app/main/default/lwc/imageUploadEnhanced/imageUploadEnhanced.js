import { LightningElement, api, track } from 'lwc';
import { processImage } from 'lightning/mediaUtils';

export default class ImageUploadEnhanced extends LightningElement {
    @api displayLabel = 'Image Upload';
    @api targetWidth;
    @api targetHeight;
    @api compressionQuality;
    @api preserveTransparency = false;
    @api backgroundColor = 'white';
    @api previewMessage;
    @api previewWidth;
    @api previewHeight;
    @api preserveAspectRatio = false;

    @api fileSize = null;
    @api fileName;
    @api imageData;
    @api imageData64;
    @api fileExtension;
    @api error = null;

    @track _previewVisible = false;

    get hasPreview() {
        return !!this.imageData;
    }

    get previewMessageStyle() {
        return this.previewWidth ? `width: ${this.previewWidth}px` : '';
    }

    get previewImageStyle() {
        const parts = [];
        if (this.previewWidth) {
            parts.push(`width: ${this.previewWidth}px`);
        }
        if (this.previewHeight) {
            parts.push(`height: ${this.previewHeight}px`);
        }
        return parts.join('; ');
    }

    get previewImageClass() {
        return this.preserveAspectRatio ? 'preview-image-contain' : 'preview-image';
    }

    get previewContainerClass() {
        return `fade-in slds-p-around_medium${this._previewVisible ? ' visible' : ''}`;
    }

    async handleImageUpload(event) {
        this.error = null;
        const files = event.target.files;
        if (!files || files.length === 0) {
            return;
        }

        const file = files[0];
        if (!file.type.startsWith('image/')) {
            this.error = 'Please select an image file.';
            return;
        }

        try {
            const blob = await processImage(file, {
                resizeMode: 'contain',
                resizeStrategy: 'reduce',
                targetWidth: this.targetWidth,
                targetHeight: this.targetHeight,
                compressionQuality: this.compressionQuality,
                imageSmoothingEnabled: true,
                preserveTransparency: this.preserveTransparency,
                backgroundColor: this.backgroundColor
            });

            if (this.imageData) {
                URL.revokeObjectURL(this.imageData);
            }

            this.imageData = URL.createObjectURL(blob);
            this.fileName = file.name;
            this.fileSize = blob.size;
            this.imageData64 = await this.convertBlobToBase64(blob);
            this.fileExtension = this.preserveTransparency ? '.png' : '.jpg';
            this._previewVisible = false;
            requestAnimationFrame(() => {
                this._previewVisible = true;
            });

            this.dispatchEvent(
                new CustomEvent('imageready', {
                    detail: {
                        imageData: this.imageData,
                        imageData64: this.imageData64,
                        fileSize: this.fileSize,
                        fileName: this.fileName,
                        fileExtension: this.fileExtension
                    }
                })
            );
        } catch (err) {
            this.error = err?.message || 'Error processing image. Please try again.';
        }
    }

    convertBlobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => {
                const result = reader.result;
                if (typeof result === 'string') {
                    resolve(result.split(',')[1]);
                } else {
                    reject(new Error('Failed to read image'));
                }
            };
            reader.onerror = () => reject(reader.error || new Error('Failed to read image'));
            reader.readAsDataURL(blob);
        });
    }

    @api
    reset() {
        if (this.imageData) {
            URL.revokeObjectURL(this.imageData);
        }
        this.imageData = null;
        this.imageData64 = null;
        this.fileName = null;
        this.fileSize = null;
        this.fileExtension = null;
        this.error = null;
        this._previewVisible = false;
        const input = this.template.querySelector('input[type="file"]');
        if (input) {
            input.value = '';
        }
    }

    disconnectedCallback() {
        if (this.imageData) {
            URL.revokeObjectURL(this.imageData);
        }
    }
}
