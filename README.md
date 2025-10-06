# dynatrace-mcp-server-kubernetes

The Dynatrace MCP Server in a Kubernetes Deployment

## Setup and Usage

### Prerequisites

- Docker installed
- Kubernetes cluster configured
- Node.js installed

### Steps

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Run the application locally**

   ```bash
   npm start
   ```

3. **Build Docker image**

   ```bash
   docker build -t dynatrace-mcp-server .
   ```

4. **Run Docker container**

   ```bash
   docker run -p 3000:3000 dynatrace-mcp-server
   ```

5. **Deploy to Kubernetes**

   ```bash
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

6. **Access the application**

   - Use the external IP of the LoadBalancer service to access the application.
