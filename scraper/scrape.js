const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
    const url = process.env.SCRAPE_URL || 'https://en.wikipedia.org/wiki/Cat';
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    try {
        const page = await browser.newPage();
        await page.goto(url, { waitUntil: 'networkidle2' });
        
        const data = await page.evaluate(() => ({
            title: document.title,
            headings: Array.from(document.querySelectorAll('h1, h2, h3')).map(h => h.textContent.trim()),
            firstParagraph: document.querySelector('p')?.textContent.trim() || ''
        }));
        
        fs.writeFileSync('/app/scraped_data.json', JSON.stringify(data));
    } finally {
        await browser.close();
    }
})();