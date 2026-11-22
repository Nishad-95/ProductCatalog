import request from 'supertest';
import { createApp } from '../../src/app';
import { FakeStoreAdapter } from '../../src/adapters/fake-store/fake-store-adapter';
import { ConsoleEmailAdapter } from '../../src/adapters/email/console-email-adapter';

describe('Product Catalog API (Integration Tests)', () => {
  let app: ReturnType<typeof createApp>;
  let emailAdapter: ConsoleEmailAdapter;

  beforeAll(() => {
    // In integration tests, use the FakeStoreAdapter (which falls back gracefully to SEED_PRODUCTS if offline)
    const dataSource = new FakeStoreAdapter();
    emailAdapter = new ConsoleEmailAdapter('test-sales@productcatalog.local');
    app = createApp({ dataSource, emailService: emailAdapter });
  });

  beforeEach(() => {
    emailAdapter.clearSentEmails();
  });

  describe('GET /api/v1/health', () => {
    it('returns status 200 with service health info', async () => {
      const res = await request(app).get('/api/v1/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ok');
      expect(res.body.service).toBe('product-catalog-api');
    });
  });

  describe('Home Page: GET /api/v1/products/featured', () => {
    it('returns top 5 featured products', async () => {
      const res = await request(app).get('/api/v1/products/featured');
      expect(res.status).toBe(200);
      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data).toHaveLength(5);

      // Verify that all items have required fields
      const first = res.body.data[0];
      expect(first).toHaveProperty('id');
      expect(first).toHaveProperty('title');
      expect(first).toHaveProperty('price');
      expect(first).toHaveProperty('rating');
    });

    it('also supports query param GET /api/v1/products?featured=true', async () => {
      const res = await request(app).get('/api/v1/products?featured=true');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(5);
    });
  });

  describe('Category Page: GET /api/v1/categories and GET /api/v1/categories/:category', () => {
    it('returns list of categories', async () => {
      const res = await request(app).get('/api/v1/categories');
      expect(res.status).toBe(200);
      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data.length).toBeGreaterThan(0);
      expect(res.body.data).toContain("electronics");
    });

    it('returns top-rated and additional products for category', async () => {
      const res = await request(app).get('/api/v1/categories/electronics');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('category', 'electronics');
      expect(res.body.data).toHaveProperty('topRated');
      expect(res.body.data).toHaveProperty('additionalProducts');
      expect(res.body.data.topRated).toBeInstanceOf(Array);
      expect(res.body.data.additionalProducts).toBeInstanceOf(Array);
      expect(res.body.data.totalCount).toBeGreaterThan(0);
    });
  });

  describe('Search: GET /api/v1/products/search?q=...', () => {
    it('returns products matching search query', async () => {
      const res = await request(app).get('/api/v1/products/search?q=backpack');
      expect(res.status).toBe(200);
      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data.length).toBeGreaterThan(0);
      expect(res.body.data[0].title.toLowerCase()).toContain('backpack');
    });

    it('returns empty array when no products match', async () => {
      const res = await request(app).get('/api/v1/products/search?q=xyznonexistentterm123');
      expect(res.status).toBe(200);
      expect(res.body.data).toEqual([]);
    });
  });

  describe('Product Details: GET /api/v1/products/:id', () => {
    it('returns product details for valid ID', async () => {
      const res = await request(app).get('/api/v1/products/1');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('id', 1);
      expect(res.body.data).toHaveProperty('title');
      expect(res.body.data).toHaveProperty('description');
      expect(res.body.data).toHaveProperty('image');
    });

    it('returns 404 for non-existent product ID', async () => {
      const res = await request(app).get('/api/v1/products/99999');
      expect(res.status).toBe(404);
      expect(res.body.error).toHaveProperty('code', 'NOT_FOUND');
    });

    it('returns 400 for non-numeric product ID', async () => {
      const res = await request(app).get('/api/v1/products/invalid-id');
      expect(res.status).toBe(400);
      expect(res.body.error).toHaveProperty('code', 'INVALID_ID');
    });
  });

  describe('Enquiry: POST /api/v1/enquiries', () => {
    it('successfully submits enquiry and records email', async () => {
      const payload = {
        productId: 1,
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        phone: '123-456-7890',
        message: 'Could you give me a quote for 10 units?',
      };

      const res = await request(app)
        .post('/api/v1/enquiries')
        .send(payload);

      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.success).toBe(true);
      expect(res.body.data.message).toContain('Thank you');

      // Verify email was logged/sent
      const sentEmails = emailAdapter.getSentEmails();
      expect(sentEmails).toHaveLength(1);
      expect(sentEmails[0].enquiry.productId).toBe(1);
      expect(sentEmails[0].enquiry.name).toBe('Sarah Connor');
    });

    it('returns 400 validation error if required fields are missing', async () => {
      const payload = {
        productId: 1,
        // name is missing
        email: 'not-an-email',
        message: 'hi', // too short
      };

      const res = await request(app)
        .post('/api/v1/enquiries')
        .send(payload);

      expect(res.status).toBe(400);
      expect(res.body.error).toHaveProperty('code', 'VALIDATION_ERROR');
    });

    it('returns 404 if enquiry is for a non-existent product', async () => {
      const payload = {
        productId: 99999,
        name: 'John Doe',
        email: 'john@example.com',
        message: 'I would like to purchase this product.',
      };

      const res = await request(app)
        .post('/api/v1/enquiries')
        .send(payload);

      expect(res.status).toBe(404);
      expect(res.body.error).toHaveProperty('code', 'NOT_FOUND');
    });
  });
});
