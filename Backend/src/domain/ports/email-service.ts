import { Enquiry } from '../models/enquiry';

export interface EmailService {
  /**
   * Dispatches an email notification to the sales inbox when a customer submits an enquiry.
   * @param enquiry The customer enquiry details.
   * @returns Promise resolving to true if sent successfully.
   */
  sendEnquiryNotification(enquiry: Enquiry): Promise<boolean>;

  /**
   * Optional inspection helper for local testing and verification.
   */
  getSentEmails?(): Array<{ to: string; subject: string; body: string; timestamp: string; enquiry: Enquiry }>;
}
