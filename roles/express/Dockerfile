FROM node:20

# Create app directory
WORKDIR /app

# Copy package files and install
COPY package*.json ./
RUN npm install --omit=dev

# Copy the rest of the code
COPY . .

# Define environment variables (editable via .env)
ENV PORT=3000

EXPOSE 3000

CMD ["node", "index.js"]
