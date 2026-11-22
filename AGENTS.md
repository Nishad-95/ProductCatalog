# AGENTS.md - ProductCatalog

This document is the single source of truth and context guide for AI agents working in the **ProductCatalog** repository.

---

## 1. Project Background & Vision

**ProductCatalog** is an extensible MVP product catalogue application designed for an entrepreneur validating a custom commercial idea.
- **Business Goal**: Customers can browse, search products, view details, and submit product enquiries that notify sales.
- **Foundation Requirement**: The client has been burned by throwaway prototypes. This codebase is built as a **durable, extensible foundation** that will evolve (e.g., swapping FakeStore for a custom database, swapping email providers for AWS SES/SendGrid, updating UI styling).
- **Metadata Source**: Fake Store API (`https://fakestoreapi.com`) is used for initial catalogue data, backed by an offline seed dataset for resilience.
- **Monorepo Layout**:
  - `Backend/`: Node.js + TypeScript (Express) REST API.
  - `iOS/`: Native Swift (SwiftUI) mobile client application.

---

## 2. Hard Technical Constraints & Policies

1. **Client & Backend Choices**:
   - Backend: **Node.js (TypeScript / Express)**.
   - Client: **Swift (SwiftUI)** for iOS.
2. **Never Call External Data Sources from Client**:
   - The iOS client **must NEVER** call the Fake Store API directly. All product queries and mutations must flow through the backend API.
3. **AWS Compatibility**:
   - Infrastructure must be compatible with AWS. The backend includes a multi-stage `Dockerfile` (Node 22 Alpine) and `docker-compose.yml` ready for AWS ECS / App Runner.
4. **Local Reviewer Experience (< 10 Minutes Setup)**:
   - Zero paid accounts or external API keys needed.
   - Backend runs with `cd Backend && npm install --legacy-peer-deps && npm run dev`.
   - Client runs directly on iOS Simulator pointing to `http://localhost:3000/api/v1`.
5. **Security & Secrets**:
   - Never commit `.env` or credentials. Maintain `.env.example`.
6. **Git / Commit Behavior (STRICT)**:
   - **DO NOT stage (`git add`) or commit (`git commit`) changes automatically.** Always leave changes in the working directory for the user to review and commit, unless the user explicitly requests a commit.

---

## 3. Acceptance Criteria (Core User Journeys)

1. **Home Page**:
   - GIVEN 5 products are designated as "top rated"
   - WHEN viewing the home page
   - THEN see those 5 featured products.
2. **Category Page**:
   - GIVEN products are organized into categories
   - WHEN clicking a category link
   - THEN see top-rated products for that category AND additional products in that category.
3. **Search**:
   - GIVEN looking for a product and entered a query in the search bar
   - WHEN clicking search (or searching live)
   - THEN only see products matching that search term (in title, description, or category).
4. **Product Page**:
   - GIVEN browsing products
   - WHEN tapping a product tile
   - THEN see the product details page (image, title, price, category, rating, description, and "Enquire" action).
5. **Enquiry**:
   - GIVEN viewing a product and tapping "Enquire"
   - AND completing the contact form (name, email, optional phone, message)
   - WHEN submitting the form
   - THEN the sales inbox receives an email notification
   - AND the customer sees a "Thank you" confirmation message.

---

## 4. Backend Architecture (`Backend/`)

### Architecture Pattern: Ports & Adapters (Hexagonal Architecture)

```text
Backend/
├── .env.example              # Environment variables template
├── Dockerfile                # AWS-compatible multi-stage container
├── jest.config.js            # Jest testing configuration
├── package.json              # Express, TypeScript, Zod, Supertest
├── tsconfig.json             # TypeScript configuration
├── src/
│   ├── app.ts                # Express setup, middleware, error handler
│   ├── server.ts             # Process lifecycle & HTTP listener
│   ├── config/
│   │   └── env.ts            # Typed configuration loaded with Zod
│   ├── domain/
│   │   ├── models/
│   │   │   ├── product.ts    # Product, ProductRating, CategoryView
│   │   │   └── enquiry.ts    # Enquiry, EnquiryInput, EnquiryResult
│   │   └── ports/
│   │       ├── product-data-source.ts  # Port: ProductDataSource
│   │       └── email-service.ts        # Port: EmailService
│   ├── adapters/
│   │   ├── fake-store/
│   │   │   ├── fake-store-adapter.ts   # Adapter with TTL cache & seed fallback
│   │   │   └── seed-data.ts            # 20 offline FakeStore products
│   │   └── email/
│   │       └── console-email-adapter.ts# Logs to stdout & retains in memory
│   ├── services/
│   │   ├── product.service.ts          # Featured top 5, category view, search
│   │   └── enquiry.service.ts          # Validation, product lookup, notification
│   ├── controllers/
│   │   ├── product.controller.ts
│   │   ├── category.controller.ts
│   │   └── enquiry.controller.ts
│   ├── routes/
│   │   ├── product.routes.ts
│   │   ├── category.routes.ts
│   │   ├── enquiry.routes.ts
│   │   └── index.ts          # Route aggregation & dependency injection
│   └── middleware/
│       ├── request-logger.ts
│       └── error-handler.ts  # Standard error envelope
└── tests/
    ├── unit/
    │   ├── product.service.test.ts
    │   └── enquiry.service.test.ts
    └── integration/
        └── api.test.ts       # Supertest integration tests
```

### Key Extensibility Invariants
- **`ProductDataSource` port**: To swap FakeStore for PostgreSQL / DynamoDB / Shopify, create a new class implementing `ProductDataSource` and inject it in `src/routes/index.ts`.
- **`EmailService` port**: To swap the console logger for AWS SES or SendGrid, implement `EmailService` and inject it.

---

## 5. Backend API Contract

### Response Envelope Standards
- **Success**: `{ "data": <payload> }`
- **Error**: `{ "error": { "code": "<CODE>", "message": "<message>", "details?": [...] } }`

### Endpoints

| Method | Path | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/health` | Service health check (`status`, `uptime`). |
| `GET` | `/api/v1/products` | All products (supports `?featured=true` and `?search=<query>`). |
| `GET` | `/api/v1/products/featured` | Top 5 products by `rating.rate` descending. |
| `GET` | `/api/v1/products/:id` | Single product details (returns 404 if not found). |
| `GET` | `/api/v1/products/search?q=:query` | Search matching title, description, or category. |
| `GET` | `/api/v1/categories` | Array of all category names: `string[]`. |
| `GET` | `/api/v1/categories/:category` | Category view: `{ category, topRated: Product[], additionalProducts: Product[], totalCount }`. |
| `POST` | `/api/v1/enquiries` | Submit enquiry. Body: `{ productId: number, name: string, email: string, phone?: string, message: string }`. Returns `{ data: EnquiryResult }`. |

---

## 6. iOS Client Architecture (`iOS/`)

- **Language & Target**: Swift 6, SwiftUI, iOS 17+.
- **Pattern**: MVVM (Model-View-ViewModel) with Clean Architecture separation:
  - `Models/`: Codable structs matching the backend API contracts (`Product`, `CategoryView`, `Enquiry`, `APIResponse<T>`).
  - `Services/`: `CatalogAPIService` handling HTTP calls to `http://localhost:3000/api/v1` using `URLSession` and Swift Concurrency (`async`/`await`).
  - `ViewModels/`:
    - `HomeViewModel`: Loads top-5 featured products and category chips.
    - `CategoryViewModel`: Loads category view with top-rated and additional products.
    - `SearchViewModel`: Debounced product search.
    - `ProductDetailViewModel`: Single product state and enquiry triggers.
    - `EnquiryViewModel`: Form state validation and submission.
  - `Views/`: SwiftUI components with clear loading, empty, and error alert states.
- **Simulator Networking Note**: Use `http://127.0.0.1:3000/api/v1` or `http://localhost:3000/api/v1` for iOS Simulator. Ensure `NSAppTransportSecurity` allows local HTTP in `Info.plist` for development.

---

## 7. Developer & Agent Cheat Sheet

### Backend Commands
```bash
cd Backend
npm install --legacy-peer-deps --cache /tmp/npm-cache   # Install dependencies
npm run dev                                            # Run local dev server (port 3000)
npm run build                                          # Compile TypeScript to dist/
npm test                                               # Run unit & integration test suites
npm run test:coverage                                  # Run tests with coverage table
```

### Docker Commands
```bash
docker compose up --build                              # Run containerized backend
```

### Code Style & Safety Guidelines
- Use explicit types in TypeScript and Swift.
- Adhere to Conventional Commits format when user requests commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
- Always preserve existing comments and documentation unless explicitly superseded.
- Never write credentials or tokens directly in source files.
