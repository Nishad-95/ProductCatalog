# ProductCatalog

A production-grade, extensible Product Catalog application built with a **Node.js (TypeScript)** backend and a **Native Swift (SwiftUI)** iOS client application.

---

## 1. Architectural Overview & Technology Choices

### Tech Stack Selection & Justification

| Layer | Chosen Technology | Why This Choice? |
| :--- | :--- | :--- |
| **Backend** | **Node.js with TypeScript (Express)** | **High concurrency, rich ecosystem, and rapid development**: Node.js handles I/O-bound catalog queries and asynchronous email notifications with minimal latency. TypeScript provides compile-time safety and strict interface definitions, making contract alignment with the client seamless. |
| **Client** | **iOS Native (Swift 6 / SwiftUI)** | **Superior user experience and native performance**: A native iOS mobile client provides smooth animations, responsive touch interactions, offline resilience, and deep platform integration (such as native navigation, haptics, and accessible design) that exceeds cross-platform or web wrappers. |

### Foundation That Can Grow & Evolve (Hexagonal / Clean Architecture)

The entrepreneur emphasized:
> *"They have been burned by throwaway prototypes before. They do not want a proof of concept that gets thrown away; they want a foundation that can grow and evolve with the vision. For example, the product data source, look and feel, and email provider are all expected to change."*

To satisfy this core requirement, the backend employs **Ports & Adapters (Hexagonal Architecture)**:

```text
┌─────────────────────────────────────────────────────────────┐
│                       HTTP Layer                            │
│           (Express Controllers, Routes & Middleware)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Services                     │
│               ProductService | EnquiryService               │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼ (Port Interface)             ▼ (Port Interface)
      ┌──────────────────┐           ┌──────────────────┐
      │ProductDataSource │           │   EmailService   │
      └────────▲─────────┘           └────────▲─────────┘
               │                              │
    ┌──────────┴──────────┐        ┌──────────┴──────────┐
    │ (Adapter)           │        │ (Adapter)           │
    │ FakeStoreAdapter    │        │ ConsoleEmailAdapter │
    │ (with offline seed  │        │ (or SESAdapter /    │
    │  & cache fallback)  │        │  NodemailerAdapter) │
    └─────────────────────┘        └─────────────────────┘
```

1. **Swappable Product Data Source**: The core domain interacts with `ProductDataSource` port. `FakeStoreAdapter` implements this port with automatic in-memory caching and resilient offline fallback. When migrating to PostgreSQL, DynamoDB, MongoDB, or Shopify, only a new adapter class needs to be implemented.
2. **Swappable Email / Notification Service**: The `EmailService` port decouples email delivery. In local development and review, `ConsoleEmailAdapter` formats and logs notifications to stdout and tracks them in memory. Connecting AWS SES, SendGrid, or SMTP requires zero changes to core business logic.
3. **AWS Compatibility**: Includes a production-ready multi-stage `Dockerfile` (optimized Alpine runner) and `docker-compose.yml`, ready to deploy directly to AWS ECS (Fargate), AWS App Runner, or AWS Elastic Beanstalk.

---

## 2. Acceptance Criteria Coverage

| Feature | Acceptance Criteria | Backend Implementation |
| :--- | :--- | :--- |
| **Home Page** | 5 top-rated products featured on home page | `GET /api/v1/products/featured` (or `?featured=true`) sorts catalog by `rating.rate` desc and `rating.count` desc, returning top 5 products. |
| **Category Page** | Categories with top-rated products + additional products | `GET /api/v1/categories` lists categories.<br>`GET /api/v1/categories/:category` splits products into `topRated` and `additionalProducts`. |
| **Search** | Search products matching text query | `GET /api/v1/products/search?q=:query` searches across title, description, and category. |
| **Product Page** | Detailed product information | `GET /api/v1/products/:id` returns comprehensive product details. |
| **Enquiry** | Submit contact enquiry, notify sales inbox, thank you response | `POST /api/v1/enquiries` validates input, verifies product exists, dispatches notification via `EmailService`, and returns confirmation. |

---

## 3. Quick Start (Run Locally in Under 5 Minutes)

### Prerequisites
- **Node.js**: v18+ (tested on Node 22)
- **npm**: v9+
- *(Optional)* **Docker**: For containerized execution

### Option A: Running with Node / npm (Recommended)

1. **Navigate to the Backend directory**:
   ```bash
   cd Backend
   ```

2. **Install dependencies**:
   ```bash
   npm install --legacy-peer-deps
   ```

3. **Configure Environment Variables**:
   ```bash
   cp .env.example .env
   ```
   *(Defaults in `.env.example` run out of the box with zero external accounts or paid services required).*

4. **Start the API Server**:
   ```bash
   # Development mode with hot-reload:
   npm run dev

   # Or compile and start production build:
   npm run build && npm start
   ```
   The API will be live at: `http://localhost:3000/api/v1`  
   Health check: `http://localhost:3000/api/v1/health`

### Option B: Running with Docker Compose

From the repository root:
```bash
docker compose up --build
```

---

## 4. Running Backend Tests

The backend includes comprehensive **unit tests** and **integration tests** covering all use cases, edge cases, error conditions, and acceptance criteria:

```bash
cd Backend
npm test
```

To run with coverage reporting:
```bash
npm run test:coverage
```

---

## 5. API Reference

All responses follow standard JSON envelopes:
- **Success**: `{ "data": ... }`
- **Error**: `{ "error": { "code": "...", "message": "..." } }`

### Endpoints

- **Health Check**: `GET /api/v1/health`
- **List All Products**: `GET /api/v1/products`
- **Featured Products (Top 5)**: `GET /api/v1/products/featured`
- **Product Details**: `GET /api/v1/products/:id`
- **Search Products**: `GET /api/v1/products/search?q=:query`
- **List Categories**: `GET /api/v1/categories`
- **Category View**: `GET /api/v1/categories/:category`
- **Submit Enquiry**: `POST /api/v1/enquiries`
  - Body:
    ```json
    {
      "productId": 1,
      "name": "Jane Doe",
      "email": "jane@example.com",
      "phone": "+1-555-0199",
      "message": "I would like to inquire about bulk ordering."
    }
    ```
  - Response:
    ```json
    {
      "data": {
        "id": "enq_1732252800000_abc123",
        "success": true,
        "message": "Thank you for your enquiry. Our sales team will get back to you shortly.",
        "receivedAt": "2026-11-22T05:00:00.000Z"
      }
    }
    ```

---

## 6. iOS Client Application

*(See the `iOS/` directory for the native Swift iOS client implementation).*
