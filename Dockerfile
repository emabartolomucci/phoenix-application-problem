# Import the required Node version (alpine for reduced size)
FROM node:8.11.1-alpine

# Create the application directory
WORKDIR /usr/src/app

# Install all app dependencies
COPY app/package*.json ./
RUN npm install

# Copy the app tree
COPY ./app .

# Start the app
CMD ["npm", "start"]
