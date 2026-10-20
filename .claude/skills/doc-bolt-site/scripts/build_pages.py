"""Turn an Artifact page (no <html>/<head>) into a standalone GitHub Pages index.html.
usage: python3 build_pages.py SRC.html OUT_DIR PUBLIC_URL "説明文"
"""
import sys, html, pathlib, shutil
src, out, url, desc = sys.argv[1:5]
s = pathlib.Path(src).read_text()
cut = s.index('</style>') + len('</style>')
head, body = s[:cut], s[cut:]
title = head[head.index('<title>')+7:head.index('</title>')]
meta = f'''<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta property="og:type" content="website">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(desc)}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{url}og.png">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 32'%3E%3Cpath d='M14 1 3 18h7l-3 13 12-18h-7z' fill='%23f2b705' stroke='%23272b33' stroke-width='2'/%3E%3C/svg%3E">
<style>:root{{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}}body{{margin:0}}img{{max-width:100%}}[hidden]{{display:none!important}}</style>
'''
outp = pathlib.Path(out); outp.mkdir(parents=True, exist_ok=True)
(outp/'index.html').write_text(meta + head.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','') + '\n</head>\n<body>\n' + body + '\n</body>\n</html>\n')
for f in pathlib.Path(src).parent.glob('*.png'):
    shutil.copy(f, outp/f.name)
print('built', outp/'index.html')
