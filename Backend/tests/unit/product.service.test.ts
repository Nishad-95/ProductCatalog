import { ProductService } from '../../src/services/product.service';
import { ProductDataSource } from '../../src/domain/ports/product-data-source';
import { Product } from '../../src/domain/models/product';

describe('ProductService (Unit Tests)', () => {
  const mockProducts: Product[] = [
    {
      id: 1,
      title: 'Alpha Shirt',
      price: 20,
      description: 'Comfortable cotton shirt',
      category: 'clothing',
      image: 'https://example.com/1.jpg',
      rating: { rate: 4.5, count: 100 },
    },
    {
      id: 2,
      title: 'Beta Pants',
      price: 40,
      description: 'Durable denim pants',
      category: 'clothing',
      image: 'https://example.com/2.jpg',
      rating: { rate: 4.8, count: 200 },
    },
    {
      id: 3,
      title: 'Gamma Watch',
      price: 150,
      description: 'Smart digital wristwatch',
      category: 'electronics',
      image: 'https://example.com/3.jpg',
      rating: { rate: 4.9, count: 50 },
    },
    {
      id: 4,
      title: 'Delta Headphones',
      price: 80,
      description: 'Wireless noise cancelling headphones',
      category: 'electronics',
      image: 'https://example.com/4.jpg',
      rating: { rate: 4.2, count: 300 },
    },
    {
      id: 5,
      title: 'Epsilon Laptop Bag',
      price: 50,
      description: 'Waterproof laptop travel bag',
      category: 'accessories',
      image: 'https://example.com/5.jpg',
      rating: { rate: 4.8, count: 250 }, // higher count than Beta Pants
    },
    {
      id: 6,
      title: 'Zeta Shoes',
      price: 90,
      description: 'Running athletic sneakers',
      category: 'clothing',
      image: 'https://example.com/6.jpg',
      rating: { rate: 3.5, count: 40 },
    },
  ];

  let mockDataSource: jest.Mocked<ProductDataSource>;
  let productService: ProductService;

  beforeEach(() => {
    mockDataSource = {
      getAllProducts: jest.fn().mockResolvedValue(mockProducts),
      getProductById: jest.fn().mockImplementation(async (id: number) => {
        return mockProducts.find((p) => p.id === id) || null;
      }),
      getCategories: jest.fn().mockResolvedValue(['clothing', 'electronics', 'accessories']),
      getProductsByCategory: jest.fn().mockImplementation(async (category: string) => {
        return mockProducts.filter((p) => p.category.toLowerCase() === category.toLowerCase());
      }),
    };

    productService = new ProductService(mockDataSource);
  });

  describe('getFeaturedProducts (Acceptance Criteria: Home Page)', () => {
    it('returns top 5 rated products sorted by rating.rate desc, then count desc', async () => {
      const featured = await productService.getFeaturedProducts(5);

      expect(featured).toHaveLength(5);
      // Expected order:
      // 1: id 3 (rate 4.9, count 50)
      // 2: id 5 (rate 4.8, count 250)
      // 3: id 2 (rate 4.8, count 200)
      // 4: id 1 (rate 4.5, count 100)
      // 5: id 4 (rate 4.2, count 300)
      expect(featured.map((p) => p.id)).toEqual([3, 5, 2, 1, 4]);
    });
  });

  describe('getCategoryView (Acceptance Criteria: Category Page)', () => {
    it('returns top rated products and additional products for a given category', async () => {
      const categoryView = await productService.getCategoryView('clothing', 2);

      expect(categoryView.category).toBe('clothing');
      expect(categoryView.totalCount).toBe(3);
      // Clothing has id 1 (4.5), id 2 (4.8), id 6 (3.5)
      // Top 2 should be: id 2 (4.8) and id 1 (4.5)
      expect(categoryView.topRated.map((p) => p.id)).toEqual([2, 1]);
      // Additional product should be id 6 (3.5)
      expect(categoryView.additionalProducts.map((p) => p.id)).toEqual([6]);
    });

    it('handles empty category gracefully', async () => {
      const categoryView = await productService.getCategoryView('non-existent');
      expect(categoryView.topRated).toEqual([]);
      expect(categoryView.additionalProducts).toEqual([]);
      expect(categoryView.totalCount).toBe(0);
    });
  });

  describe('searchProducts (Acceptance Criteria: Search)', () => {
    it('returns only products matching search term in title', async () => {
      const results = await productService.searchProducts('shirt');
      expect(results).toHaveLength(1);
      expect(results[0].id).toBe(1);
    });

    it('returns products matching search term in description', async () => {
      const results = await productService.searchProducts('noise cancelling');
      expect(results).toHaveLength(1);
      expect(results[0].id).toBe(4);
    });

    it('returns products matching search term in category', async () => {
      const results = await productService.searchProducts('electronics');
      expect(results).toHaveLength(2);
      expect(results.map((p) => p.id)).toEqual([3, 4]);
    });

    it('returns empty array when search query is empty or whitespace', async () => {
      const results = await productService.searchProducts('   ');
      expect(results).toEqual([]);
    });

    it('is case-insensitive', async () => {
      const results = await productService.searchProducts('ALPHA');
      expect(results).toHaveLength(1);
      expect(results[0].id).toBe(1);
    });
  });

  describe('getProductById (Acceptance Criteria: Product Details)', () => {
    it('returns product details when product exists', async () => {
      const product = await productService.getProductById(3);
      expect(product).not.toBeNull();
      expect(product?.title).toBe('Gamma Watch');
    });

    it('returns null when product does not exist', async () => {
      const product = await productService.getProductById(999);
      expect(product).toBeNull();
    });
  });
});
