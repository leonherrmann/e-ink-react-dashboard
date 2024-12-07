# Build React App
FROM node:18 as react-build
WORKDIR /app
COPY src/frontend/package.json /app/
COPY src/frontend/package-lock.json /app/
RUN npm install
COPY src/frontend /app
RUN npm run build

# Run Backend
FROM node:18

# Install build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev

WORKDIR /app
COPY src/package.json /app/
COPY src/package-lock.json /app/
RUN npm install

COPY src /app/
COPY --from=react-build /app/build /app/frontend/build

CMD ["node", "server.js"]