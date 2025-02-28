export class ImageAttachmentModel {
    signedId: number | null;
    url: string;
    file: File | null = null;

    constructor(signed_id: number | null, url: string, file: File | null = null) {
        this.file = file;
        this.signedId = signed_id;
        this.url = url;
    }

    static fromAPI(data: any): ImageAttachmentModel | null {
        if (!data) {
            return null;
        }
        return new ImageAttachmentModel(
            data.signed_id,
            data.url
        );
    }
}