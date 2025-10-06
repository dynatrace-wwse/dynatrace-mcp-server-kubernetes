# Use the official Node.js image as the base image
FROM node:20

# Expose the application port
EXPOSE 3000

# Command to run the application
CMD ["npx", "-y", "@dynatrace-oss/dynatrace-mcp-server@latest", "--http", "--port", "3000"]