# Use Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install
COPY package*.json ./
RUN npm install

# Copy all app files
COPY . .

# Expose port
EXPOSE 8080

# Start app
CMD ["npm", "start"]
