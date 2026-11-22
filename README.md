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

## 2. Acceptance Criteria & Design Assumptions

Below is the mapping of each user journey acceptance criteria (AC) to its implementation details and the explicit assumptions made to deliver a robust, user-friendly MVP.

---

### 1. Home Page
- **Acceptance Criteria**:
  > **GIVEN** I have chosen 5 products to be "top rated"  
  > **WHEN** I am viewing the home page  
  > **THEN** I see those 5 featured products.
- **Assumptions & Design Decisions**:
  - **Feed Composition**: The Home screen displays the top 5 featured products in a dedicated featured section, followed by the remaining catalogue products in a 2-column grid.
  - **Backend-Driven Selection**: Featured products are determined server-side—either configured explicitly by ID via `FEATURED_PRODUCT_IDS` in `.env` or dynamically calculated by highest rating score (`rating.rate`) and review count (`rating.count`). The iOS client never hardcodes or arbitrarily selects featured items.
  - **Default Category**: The default category filter on app launch is `"All"`, immediately presenting customers with featured items and the full product catalogue.

---

### 2. Category Page & Filtering
- **Acceptance Criteria**:
  > **GIVEN** my products are organised into categories  
  > **WHEN** I click on a category link  
  > **THEN** I see top rated products for that category  
  > **AND** I see additional products in that category.
- **Assumptions & Design Decisions**:
  - **Default Selection**: Default category is `"All"`. Selecting any specific category filters the view to show top-rated products for that category followed by remaining products in that category.
  - **Session-Based State**: Category selection is maintained in memory for the duration of the user session. It is intentionally **not persisted across app launches**, ensuring each fresh launch starts cleanly on `"All"`.
  - **Backend Partitioning**: The backend endpoint (`GET /api/v1/categories/:category`) performs the separation of products into `topRated` (top 5) and `additionalProducts`, keeping business partitioning logic on the server.
  - **Inline Filtering UX**: On iOS, category chips on the Home screen allow instantaneous category filtering directly on the main feed, while also supporting dedicated category navigation.

---

### 3. Search Experience
- **Acceptance Criteria**:
  > **GIVEN** I am looking for a specific product  
  > **AND** I have entered a search term in the search bar  
  > **WHEN** I click the search button  
  > **THEN** I only see products that have text matching that search term.
- **Assumptions & Design Decisions**:
  - **Multi-Field Search**: Matching searches across product **title (name)**, **description**, and **category** fields to maximize discovery.
  - **Interactive & On-Submit**: While clicking the search button / Return key immediately executes the search query as stated in the AC, the UI also features debounced search (300ms) as the customer types, providing an instant feedback loop with dedicated empty/loading states.
  - **Server-Side Execution**: Search queries are executed server-side via `GET /api/v1/products/search?q=:query` rather than client-side array filtering, ensuring scalability as the catalog grows.

---

### 4. Product Details Page
- **Acceptance Criteria**:
  > **GIVEN** I am browsing the products  
  > **AND** I want to see more details about a specific product  
  > **WHEN** I click on a product tile  
  > **THEN** I see the product details page.
- **Assumptions & Design Decisions**:
  - **No extra domain assumptions**: Displays full product metadata—high-resolution image, category tag, full title, formatted price (`$XX.XX`), interactive star rating with review count, and full description text.
  - **Prominent Action**: The page features a prominent floating "Enquire Now" call-to-action button anchored at the bottom of the screen.

---

### 5. Product Enquiry & Notification
- **Acceptance Criteria**:
  > **GIVEN** I am viewing a product  
  > **AND** I am interested in a product  
  > **AND** I click on the Enquire button  
  > **AND** I complete the subsequent form with my contact details  
  > **WHEN** I submit the form  
  > **THEN** the sales inbox will receive an email  
  > **AND** the customer will see a "Thank you" message.
- **Assumptions & Design Decisions**:
  - **Local Development Simulation (Zero Paid Services)**: Because this project runs locally with no required third-party paid accounts or external API keys, we do not dispatch real SMTP/SES emails during evaluation. Instead, submission performs a backend API call (`POST /api/v1/enquiries`), and `ConsoleEmailAdapter` formats a full email notification to `sales@productcatalog.local` and logs it to `stdout` while retaining it in memory.
  - **Form Validation**: Customer Name, valid Email address, and Message are mandatory fields. Phone number is optional. The submission button remains disabled until valid inputs are provided.
  - **Confirmation Feedback**: Upon receiving a `201 Created` response with an enquiry tracking ID (e.g. `enq_1732261948_abc123`), the modal smoothly transitions to a dedicated "Thank You!" confirmation screen with a checkmark and the reference ID.
  - **Extensible Port**: Swapping the console logger for AWS SES, SendGrid, or Resend requires zero changes to core business logic—only a new class implementing the `EmailService` port.

---

### 6. Additional Technical & Infrastructure Assumptions
- **Image Resilience & CDN Normalization**: FakeStore API image URLs (`fakestoreapi.com/img/...`) encounter HTTP 403 bot-protection blocks when requested from native iOS clients. Both the backend and client normalize these URLs to Amazon's public CDN origin (`m.media-amazon.com/images/I/...`). Additionally, an offline 20-product seed catalog is bundled so the app functions fully even without external internet access.
- **Strict Client-Server Isolation**: The iOS client **never** communicates with external data providers directly. All queries, caching, and mutations strictly flow through `http://localhost:3000/api/v1`.
- **Simulator Networking**: The iOS app targets `http://127.0.0.1:3000/api/v1` with local HTTP transport enabled via `NSAppTransportSecurity` in `Info.plist`.

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

## 6. iOS Client Application ("Catlog")

The iOS client is a native SwiftUI application engineered with **MVVM (Model-View-ViewModel)** and Clean Architecture separation:

```text
iOS/ProductCatalog/ProductCatalog/
├── Models/              # Codable & Sendable domain entities (Product, CategoryView, Enquiry)
├── Services/            # Async/await URLSession APIClient & endpoints
├── Repositories/        # ProductRepository protocol & implementation
├── Core/                # AppConfiguration, DI Container, Theme tokens
├── ViewModels/          # HomeViewModel, CategoryViewModel, ProductDetailViewModel, EnquiryViewModel
├── Views/               # HomeView, CategoryListingView, ProductDetailView, EnquirySheetView
├── Components/          # AsyncProductImage, ProductCardView, CategoryChipView, RatingBadgeView
└── Config/
    └── Info.plist       # NSAppTransportSecurity local HTTP exceptions for simulator
```

### Running the iOS App in Xcode

1. Ensure the Node.js backend is running on `http://localhost:3000`.
2. Open the Xcode project:
   ```bash
   open iOS/ProductCatalog/ProductCatalog.xcodeproj
   ```
3. Select an iOS Simulator (e.g., **iPhone 16** or **iPhone 16 Pro** running iOS 17+).
4. Press **⌘R** to build and run.

### Running iOS Unit Tests

Tests can be executed directly inside Xcode (**⌘U**) or from the command line:

```bash
cd iOS/ProductCatalog
xcodebuild -project ProductCatalog.xcodeproj \
  -scheme ProductCatalog \
  -destination 'generic/platform=iOS Simulator' \
  -only-testing:ProductCatalogTests \
  -derivedDataPath ./build test
```
