# Use an official image as a parent
FROM node:14

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN npm install

# Define entry point
CMD ["npm", "start"]
