import express from 'express';
import puppeteer from 'puppeteer';
import { createCanvas, loadImage } from 'canvas';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import { promisify } from 'util';

const app = express();
const PORT = 5001;

// Get __dirname equivalent in ES module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Serve React App
app.use(express.static(path.join(__dirname, 'frontend/build')));

// Generate image endpoint
app.get('/image', async (req, res) => {
  console.log('Received request for /image');

  const browser = await puppeteer.launch();
  console.log('Launched Puppeteer browser');

  const page = await browser.newPage();
  console.log('Opened new page in Puppeteer');

  const canvasWidth = 1280;
  const canvasHeight = 720;

  await page.setViewport({ width: canvasWidth, height: canvasHeight });
  console.log(`Set viewport to ${canvasWidth}x${canvasHeight}`);

  await page.goto(`http://localhost:${PORT}`);
  console.log(`Navigated to http://localhost:${PORT}`);

  const screenshotBuffer = await page.screenshot({ type: 'png' });
  console.log('Captured screenshot');

  // Write screenshot buffer to a temporary file
  const tempFilePath = path.join(__dirname, 'temp_screenshot.png');
  await promisify(fs.writeFile)(tempFilePath, screenshotBuffer);
  console.log('Saved screenshot to temporary file');

  // Load image from temporary file
  const img = await loadImage(tempFilePath);
  console.log('Loaded screenshot into canvas');

  // Convert to black and white
  const canvas = createCanvas(canvasWidth, canvasHeight);
  console.log('Created Canvas');
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);
  console.log('Drew image on canvas');

  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
  const bwData = new Uint8ClampedArray(imageData.data.length);

  for (let i = 0; i < imageData.data.length; i += 4) {
    // Your existing code to convert to black and white
  }
  console.log('Converted image to black and white');

  // Send the black and white image as response
  res.setHeader('Content-Type', 'image/png');
  res.send(canvas.toBuffer('image/png'));
  console.log('Sent black and white image as response');

  // Clean up temporary file
  await promisify(fs.unlink)(tempFilePath);
  console.log('Deleted temporary file');

  await browser.close();
  console.log('Closed Puppeteer browser');
});

// Catch-all route to serve React app
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'frontend/build', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});