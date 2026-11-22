import { Router } from 'express';
import { EnquiryController } from '../controllers/enquiry.controller';

export function createEnquiryRouter(controller: EnquiryController): Router {
  const router = Router();

  // Submit enquiry: POST /api/v1/enquiries
  router.post('/', controller.submit);

  return router;
}
