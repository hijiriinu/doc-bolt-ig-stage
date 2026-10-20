// usage: node render.js page.html selector outPrefix width height
const { chromium } = require('playwright');
(async () => {
  const [page, sel, prefix, w, h] = process.argv.slice(2);
  const b = await chromium.launch({executablePath:'/opt/pw-browsers/chromium'}).catch(()=>chromium.launch());
  const p = await b.newPage({viewport:{width:+w,height:+h}});
  await p.goto('file://' + require('path').resolve(page));
  await p.evaluate(() => document.fonts.ready); await p.waitForTimeout(800);
  const els = await p.$$(sel);
  for (let i = 0; i < els.length; i++) await els[i].screenshot({path: `${prefix}${i+1}.png`});
  console.log('rendered', els.length);
  await b.close();
})();
