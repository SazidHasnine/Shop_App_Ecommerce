# Evira Local Mock Server

Runs a local REST API using `json-server` for testing order creation, checkout flows, and order history.

## Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Server
```bash
npm start
```
The server will run at `http://localhost:3001` (and will be reachable from Android Emulators via `http://10.0.2.2:3001`).

### 3. Endpoints Available
- `GET  /orders` - List all orders
- `POST /orders` - Create a new order
- `GET  /orders/:id` - Fetch single order details