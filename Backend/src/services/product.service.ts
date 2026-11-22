import { CategoryView, Product } from '../domain/models/product';
import { ProductDataSource } from '../domain/ports/product-data-source';

export class ProductService {
  constructor(
    private readonly dataSource: ProductDataSource,
    private readonly configuredFeaturedIds: number[] = []
  ) {}

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
   * Retrieves the exactly 5 featured products to feature on the Home Page.
   * If configured product IDs are provided by the backend configuration, selects those IDs.
   * Otherwise (or as fallback), selects the top-rated products.
   */
  async getFeaturedProducts(limit: number = 5, overrideIds?: number[]): Promise<Product[]> {
    const all = await this.dataSource.getAllProducts();
    const targetIds = overrideIds || this.configuredFeaturedIds;

    let featured: Product[] = [];

    if (targetIds && targetIds.length > 0) {
      const productMap = new Map<number, Product>();
      all.forEach((p) => productMap.set(p.id, p));

      for (const id of targetIds) {
        const product = productMap.get(id);
        if (product && !featured.some((p) => p.id === product.id)) {
          featured.push(product);
          if (featured.length === limit) break;
        }
      }
    }

    // If fewer than limit were found from configured IDs, top-up with top-rated products
    if (featured.length < limit) {
      const existingIds = new Set(featured.map((p) => p.id));
      const remainingSorted = [...all]
        .filter((p) => !existingIds.has(p.id))
        .sort((a, b) => {
          if (b.rating.rate !== a.rating.rate) {
            return b.rating.rate - a.rating.rate;
          }
          return b.rating.count - a.rating.count;
        });

      featured = featured.concat(remainingSorted.slice(0, limit - featured.length));
    }

    return featured.slice(0, limit);
  }

  /**
   * Retrieves all unique product categories.
   */
  async getCategories(): Promise<string[]> {
    return this.dataSource.getCategories();
  }

  /**
   * Retrieves the category view for a specific category (or 'all' for complete catalogue):
   * Splits products into top-rated (featured) products for that category (at least 5 if available)
   * and additional products.
   */
  async getCategoryView(category: string, topRatedCount: number = 5): Promise<CategoryView> {
    const isAll = category.trim().toLowerCase() === 'all';
    const products = isAll
      ? await this.dataSource.getAllProducts()
      : await this.dataSource.getProductsByCategory(category);

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
