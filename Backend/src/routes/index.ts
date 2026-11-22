import { Router } from 'express';
import { FakeStoreAdapter } from '../adapters/fake-store/fake-store-adapter';
import { ConsoleEmailAdapter } from '../adapters/email/console-email-adapter';
import { ProductService } from '../services/product.service';
import { EnquiryService } from '../services/enquiry.service';
import { ProductController } from '../controllers/product.controller';
import { CategoryController } from '../controllers/category.controller';
import { EnquiryController } from '../controllers/enquiry.controller';
import { createProductRouter } from './product.routes';
import { createCategoryRouter } from './category.routes';
import { createEnquiryRouter } from './enquiry.routes';
import { config } from '../config/env';

export interface AppDependencies {
  dataSource?: FakeStoreAdapter;
  emailService?: ConsoleEmailAdapter;
}

export function createApiRouter(deps: AppDependencies = {}): Router {
  const router = Router();

  // Instantiate Adapters (Hexagonal Architecture - easily replaceable)
  const dataSource = deps.dataSource || new FakeStoreAdapter(config.FAKESTORE_API_BASE_URL, config.CACHE_TTL_SECONDS);
  const emailService = deps.emailService || new ConsoleEmailAdapter(config.SALES_EMAIL);

  // Instantiate Services
  const productService = new ProductService(dataSource);
  const enquiryService = new EnquiryService(dataSource, emailService);

  // Instantiate Controllers
  const productController = new ProductController(productService);
  const categoryController = new CategoryController(productService);
  const enquiryController = new EnquiryController(enquiryService);

  // Health check endpoint (for AWS ECS / ALB / uptime checks)
  router.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      service: 'product-catalog-api',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    });
  });

  // Mount feature routers
  router.use('/products', createProductRouter(productController));
  router.use('/categories', createCategoryRouter(categoryController));
  router.use('/enquiries', createEnquiryRouter(enquiryController));

  return router;
}
