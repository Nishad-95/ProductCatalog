import { Enquiry, EnquiryInput, EnquiryResult } from '../domain/models/enquiry';
import { EmailService } from '../domain/ports/email-service';
import { ProductDataSource } from '../domain/ports/product-data-source';

export class EnquiryService {
  constructor(
    private readonly productDataSource: ProductDataSource,
    private readonly emailService: EmailService
  ) {}

  /**
   * Processes a customer product enquiry:
   * 1. Verifies that the product exists.
   * 2. Constructs the enquiry record.
   * 3. Dispatches the email notification to the sales inbox.
   * 4. Returns confirmation for the customer.
   */
  async submitEnquiry(input: EnquiryInput): Promise<EnquiryResult> {
    const product = await this.productDataSource.getProductById(input.productId);
    if (!product) {
      const error = new Error(`Product with ID ${input.productId} was not found`);
      (error as unknown as { statusCode: number }).statusCode = 404;
      throw error;
    }

    const enquiryId = `enq_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    const enquiry: Enquiry = {
      id: enquiryId,
      productId: product.id,
      productTitle: product.title,
      name: input.name.trim(),
      email: input.email.trim().toLowerCase(),
      phone: input.phone?.trim(),
      message: input.message.trim(),
      createdAt: new Date().toISOString(),
    };

    const sent = await this.emailService.sendEnquiryNotification(enquiry);
    if (!sent) {
      const error = new Error('Failed to dispatch enquiry notification email');
      (error as unknown as { statusCode: number }).statusCode = 502;
      throw error;
    }

    return {
      id: enquiry.id,
      success: true,
      message: 'Thank you for your enquiry. Our sales team will get back to you shortly.',
      receivedAt: enquiry.createdAt,
    };
  }
}
