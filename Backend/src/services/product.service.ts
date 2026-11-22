import { CategoryView, Product } from '../domain/models/product';
import { ProductDataSource } from '../domain/ports/product-data-source';

export class ProductService {
  constructor(private readonly dataSource: ProductDataSource) {}

  /**
   * Retrieves all products.
   */
  async getAllProducts(): Promise<Product[]> {
    return this.dataSource.getAllProducts();
  }

  /**
   * Retrieves a single product by ID.
   */
  async getProductById(id: number): Promise<Product | null> {
    return this.dataSource.getProductById(id);
  }

  /**
   * Retrieves the 5 top-rated products to feature on the Home Page.
   * Sorts products by rating.rate descending, with rating.count as tie-breaker.
   */
  async getFeaturedProducts(limit: number = 5): Promise<Product[]> {
    const all = await this.dataSource.getAllProducts();
    const sorted = [...all].sort((a, b) => {
      if (b.rating.rate !== a.rating.rate) {
        return b.rating.rate - a.rating.rate;
      }
      return b.rating.count - a.rating.count;
    });
    return sorted.slice(0, limit);
  }

  /**
   * Retrieves all unique product categories.
   */
  async getCategories(): Promise<string[]> {
    return this.dataSource.getCategories();
  }

  /**
   * Retrieves the category view for a specific category:
   * Splits products into top-rated products for that category and additional products.
   */
  async getCategoryView(category: string, topRatedCount: number = 2): Promise<CategoryView> {
    const products = await this.dataSource.getProductsByCategory(category);
    if (products.length === 0) {
      return {
        category,
        topRated: [],
        additionalProducts: [],
        totalCount: 0,
      };
    }

    // Sort by rating to determine the category's top-rated products
    const sorted = [...products].sort((a, b) => {
      if (b.rating.rate !== a.rating.rate) {
        return b.rating.rate - a.rating.rate;
      }
      return b.rating.count - a.rating.count;
    });

    const topRated = sorted.slice(0, topRatedCount);
    const topRatedIds = new Set(topRated.map((p) => p.id));
    const additionalProducts = products.filter((p) => !topRatedIds.has(p.id));

    return {
      category,
      topRated,
      additionalProducts,
      totalCount: products.length,
    };
  }

  /**
   * Searches products by text match across title, description, and category.
   * Returns only products matching the query.
   */
  async searchProducts(query: string): Promise<Product[]> {
    const trimmed = query.trim().toLowerCase();
    if (!trimmed) {
      return [];
    }

    const all = await this.dataSource.getAllProducts();
    return all.filter((product) => {
      const matchTitle = product.title.toLowerCase().includes(trimmed);
      const matchDescription = product.description.toLowerCase().includes(trimmed);
      const matchCategory = product.category.toLowerCase().includes(trimmed);
      return matchTitle || matchDescription || matchCategory;
    });
  }
}
