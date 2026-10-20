import sys
from PIL import Image, ImageDraw
src, box, out = sys.argv[1], tuple(map(int, sys.argv[2].split(','))), sys.argv[3]
im = Image.open(src).convert('RGB').crop(box)
w,h = im.size
bg = im.getpixel((2,2))
# flood fill from all border pixels with a marker color
marker=(255,0,255)
for x in range(w):
    for y in (0,h-1):
        if sum(abs(a-b) for a,b in zip(im.getpixel((x,y)),bg))<40: ImageDraw.floodfill(im,(x,y),marker,thresh=40)
for y in range(h):
    for x in (0,w-1):
        if sum(abs(a-b) for a,b in zip(im.getpixel((x,y)),bg))<40: ImageDraw.floodfill(im,(x,y),marker,thresh=40)
rgba = im.convert('RGBA')
px = rgba.load()
for y in range(h):
    for x in range(w):
        if px[x,y][:3]==marker: px[x,y]=(0,0,0,0)
rgba = rgba.crop(rgba.getbbox())
rgba.thumbnail((360,360))
rgba.save(out, optimize=True)
print(out, rgba.size)
