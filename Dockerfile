ARG BUILD_FROM
FROM ${BUILD_FROM} as react-build
WORKDIR /app
COPY src/frontend/package.json /app/
COPY src/frontend/package-lock.json /app/
RUN npm install
COPY src/frontend /app
RUN npm run build

ARG BUILD_FROM
FROM ${BUILD_FROM} as main-app

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && apt-get install curl gnupg -y \
  && curl --location --silent https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install google-chrome-stable -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

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