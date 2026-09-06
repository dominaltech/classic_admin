# Classic PWA Admin — Setup & Usage Guide

Installable Progressive Web Application (PWA) for managing **Classic Collection Solapur** ([classicsolapur.com](https://classicsolapur.com)).

## Features
- **Dashboard & KPIs**: Real-time store revenue, total orders, low/out-of-stock items, and store settings (Free delivery threshold, delivery fee).
- **Orders Management**: Filter orders by status (Pending, Confirmed, Shipped, Delivered, Cancelled). View full line items, delivery address, and advance order state with audit timestamps.
- **Product Catalog**: View inventory, stock count, price per meter, and instantly delete or edit products.
- **Add Product with Cascading Taxonomy**: Select Category (Men) $\to$ Style (Formal, Casual) $\to$ Pattern (Stripes, Checks, etc.) $\to$ Material (Cotton, Linen, Khadi, Silk, Linen Cotton).
- **Supabase Storage Image Upload**: Select image files directly to upload to the `product-images` bucket on Supabase, or paste an external image URL.
- **Hero Banners Manager**: Manage homepage carousel banners, link destinations, and visibility.
- **Fabric Materials Manager**: Add or remove available fabric material options.
- **Taxonomy Manager**: Manage categories, styles, and patterns dynamically.
- **Customer Profiles**: View registered customer directory, phone contacts, and delivery addresses.

## How to Run & Install
1. Open this folder in a terminal:
   ```bash
   cd "Classic PWA Admin"
   ```
2. Serve using any static server (or VS Code Live Server):
   ```bash
   npx -y serve .
   ```
3. Open `http://localhost:3000` (or the port provided).
4. Click the **Install** icon in the browser address bar (Chrome/Edge) to install it directly as a native desktop or mobile application.

## Database & Credentials
The PWA is connected to the active project:
- **Supabase Project URL**: `https://mizbiarhnxzrpfuodqnj.supabase.co`
- Configured in [config.js](file:///c:/Users/DELL/Desktop/Classic/Classic%20PWA%20Admin/config.js).
