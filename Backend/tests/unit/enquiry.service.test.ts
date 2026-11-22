import { EnquiryService } from '../../src/services/enquiry.service';
import { ProductDataSource } from '../../src/domain/ports/product-data-source';
import { EmailService } from '../../src/domain/ports/email-service';
import { Product } from '../../src/domain/models/product';

describe('EnquiryService (Unit Tests)', () => {
  const mockProduct: Product = {
    id: 10,
    title: 'Acme Super Gadget',
    price: 99.99,
    description: 'A revolutionary gadget for everyone',
    category: 'gadgets',
    image: 'https://example.com/gadget.jpg',
    rating: { rate: 4.9, count: 50 },
  };

  let mockDataSource: jest.Mocked<ProductDataSource>;
  let mockEmailService: jest.Mocked<EmailService>;
  let enquiryService: EnquiryService;

  beforeEach(() => {
    mockDataSource = {
      getAllProducts: jest.fn(),
      getProductById: jest.fn().mockImplementation(async (id: number) => {
        return id === 10 ? mockProduct : null;
      }),
      getCategories: jest.fn(),
      getProductsByCategory: jest.fn(),
    };

    mockEmailService = {
      sendEnquiryNotification: jest.fn().mockResolvedValue(true),
    };

    enquiryService = new EnquiryService(mockDataSource, mockEmailService);
  });

  describe('submitEnquiry (Acceptance Criteria: Enquiry)', () => {
    it('successfully processes enquiry, dispatches notification, and returns thank you response', async () => {
      const input = {
        productId: 10,
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+1-555-0199',
        message: 'I am interested in bulk ordering this product for my company.',
      };

      const result = await enquiryService.submitEnquiry(input);

      expect(result.success).toBe(true);
      expect(result.message).toContain('Thank you for your enquiry');
      expect(result.id).toMatch(/^enq_/);
      expect(result.receivedAt).toBeDefined();

      // Verify email service was invoked with correct details
      expect(mockEmailService.sendEnquiryNotification).toHaveBeenCalledTimes(1);
      const calledWith = mockEmailService.sendEnquiryNotification.mock.calls[0][0];
      expect(calledWith.productId).toBe(10);
      expect(calledWith.productTitle).toBe('Acme Super Gadget');
      expect(calledWith.name).toBe('Jane Doe');
      expect(calledWith.email).toBe('jane@example.com');
      expect(calledWith.message).toBe(input.message);
    });

    it('throws 404 error when product does not exist', async () => {
      const input = {
        productId: 999,
        name: 'John Doe',
        email: 'john@example.com',
        message: 'Is this product available?',
      };

      await expect(enquiryService.submitEnquiry(input)).rejects.toThrow(
        'Product with ID 999 was not found'
      );
      expect(mockEmailService.sendEnquiryNotification).not.toHaveBeenCalled();
    });

    it('throws 502 error when email delivery fails', async () => {
      mockEmailService.sendEnquiryNotification.mockResolvedValueOnce(false);

      const input = {
        productId: 10,
        name: 'Alice',
        email: 'alice@example.com',
        message: 'Interested in this item',
      };

      await expect(enquiryService.submitEnquiry(input)).rejects.toThrow(
        'Failed to dispatch enquiry notification email'
      );
    });
  });
});
