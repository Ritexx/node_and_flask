### Running the Scraper

1. **Build the image**:
   ```bash
   docker build -t web-scraper .

2. **custom url**:
   docker run -p 8000:8000 -e SCRAPE_URL="https://example.com" web-scraper

3.**results**:
  http://localhost:8000
   
