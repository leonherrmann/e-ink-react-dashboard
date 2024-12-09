ARG BUILD_FROM
FROM ${BUILD_FROM} as react-build

RUN apk add --no-cache nodejs npm python3 make g++

WORKDIR /app
COPY src/frontend/package.json /app/
COPY src/frontend/package-lock.json /app/
RUN npm install
COPY src/frontend /app
RUN npm run build

FROM ${BUILD_FROM} as main-app

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apk add --no-cache \
    chromium \
    nodejs \
    npm

    RUN apk add --no-cache nodejs npm python3 make g++ chromium

# Set the working directory
WORKDIR /app
COPY src/package.json /app/
COPY src/package-lock.json /app/
RUN npm install

COPY src /app/
COPY --from=react-build /app/build /app/frontend/build

# Rebuild native modules
RUN npm rebuild canvas

# Expose the port
EXPOSE 5001

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

# Start the application
CMD ["/run.sh"]