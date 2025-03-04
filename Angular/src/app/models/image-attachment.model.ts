export type ImageAttachmentApi = {
    signed_id: number;
    url: string;
}

export class ImageAttachmentModel {
    signedId: number | null;
    url: string;
    file: File | null = null;

    constructor(
        signedId: number | null, 
        url: string, 
        file: File | null = null
    ) {
        this.file = file;
        this.signedId = signedId;
        this.url = url;
    }

    static fromAPI(data: ImageAttachmentApi): ImageAttachmentModel {
        return new ImageAttachmentModel(
            data.signed_id,
            data.url
        );
    }
}