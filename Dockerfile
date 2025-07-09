# Use Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy full source files
COPY . .

# Install dependencies
RUN npm install

# Expose port
EXPOSE 8080

# Start app
CMD ["npm", "start"]
