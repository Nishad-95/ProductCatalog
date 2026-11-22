import { Enquiry } from '../../domain/models/enquiry';
import { EmailService } from '../../domain/ports/email-service';

export interface SentEmailRecord {
  to: string;
  subject: string;
  body: string;
  timestamp: string;
  enquiry: Enquiry;
}

export class ConsoleEmailAdapter implements EmailService {
  private readonly salesEmail: string;
  private readonly sentEmails: SentEmailRecord[] = [];

  constructor(salesEmail: string = 'sales@productcatalog.local') {
    this.salesEmail = salesEmail;
  }

  async sendEnquiryNotification(enquiry: Enquiry): Promise<boolean> {
    const subject = `[New Product Enquiry] ${enquiry.productTitle} - From ${enquiry.name}`;
    const body = `
==================================================
                 SALES INBOX NOTIFICATION
==================================================
To: ${this.salesEmail}
Date: ${enquiry.createdAt}
Subject: ${subject}

Product Details:
  - ID: ${enquiry.productId}
  - Title: ${enquiry.productTitle}

Customer Information:
  - Name: ${enquiry.name}
  - Email: ${enquiry.email}
  - Phone: ${enquiry.phone || 'N/A'}

Customer Message:
"${enquiry.message}"
==================================================
`;

    console.log(body);

    this.sentEmails.push({
      to: this.salesEmail,
      subject,
      body,
      timestamp: new Date().toISOString(),
      enquiry,
    });

    return true;
  }

  getSentEmails(): SentEmailRecord[] {
    return [...this.sentEmails];
  }

  clearSentEmails(): void {
    this.sentEmails.length = 0;
  }
}
