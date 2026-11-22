import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { EnquiryService } from '../services/enquiry.service';

const enquirySchema = z.object({
  productId: z.number({ required_error: 'Product ID is required' }).int().positive(),
  name: z.string({ required_error: 'Name is required' }).trim().min(2, 'Name must be at least 2 characters'),
  email: z.string({ required_error: 'Email is required' }).trim().email('Invalid email address'),
  phone: z.string().trim().optional(),
  message: z.string({ required_error: 'Message is required' }).trim().min(5, 'Message must be at least 5 characters'),
});

export class EnquiryController {
  constructor(private readonly enquiryService: EnquiryService) {}

  submit = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validated = enquirySchema.parse(req.body);
      const result = await this.enquiryService.submitEnquiry(validated);
      res.status(201).json({ data: result });
    } catch (error) {
      next(error);
    }
  };
}
