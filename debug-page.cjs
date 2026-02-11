const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // 페이지 로드
  await page.goto('http://localhost:5173/login');

  // 페이지가 완전히 로드될 때까지 대기
  await page.waitForTimeout(3000);

  // 현재 HTML 출력
  const content = await page.content();
  console.log('=== PAGE CONTENT ===');
  console.log(content);

  // 콘솔 에러 확인
  page.on('console', msg => {
    console.log('CONSOLE:', msg.type(), msg.text());
  });

  // 오류 확인
  page.on('pageerror', error => {
    console.log('PAGE ERROR:', error.message);
  });

  await browser.close();
})();