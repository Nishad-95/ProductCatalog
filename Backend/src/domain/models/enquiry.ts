export interface EnquiryInput {
  productId: number;
  name: string;
  email: string;
  phone?: string;
  message: string;
}

export interface Enquiry {
  id: string;
  productId: number;
  productTitle: string;
  name: string;
  email: string;
  phone?: string;
  message: string;
  createdAt: string;
}

export interface EnquiryResult {
  id: string;
  success: boolean;
  message: string;
  receivedAt: string;
}
