const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // 콘솔 및 에러 로그 수집
  const logs = [];
  const errors = [];

  page.on('console', msg => {
    logs.push({
      type: msg.type(),
      text: msg.text(),
      location: msg.location()
    });
  });

  page.on('pageerror', error => {
    errors.push({
      message: error.message,
      stack: error.stack
    });
  });

  // 페이지 로드
  await page.goto('http://localhost:5173/login');
  await page.waitForTimeout(5000);

  console.log('=== CONSOLE LOGS ===');
  logs.forEach(log => {
    console.log(`[${log.type}] ${log.text}`);
    if (log.location) {
      console.log(`  Location: ${log.location.url}:${log.location.lineNumber}:${log.location.columnNumber}`);
    }
  });

  console.log('\n=== PAGE ERRORS ===');
  errors.forEach(error => {
    console.log(`Error: ${error.message}`);
    if (error.stack) {
      console.log(`Stack: ${error.stack}`);
    }
  });

  await browser.close();
})();