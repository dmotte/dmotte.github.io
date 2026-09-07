# dmotte.github.io

&#x1F30D; **dmotte**'s _GitHub Pages_ [website](https://dmotte.github.io/).

To **generate PNG and ICO files** from [`favicon.svg`](favicon.svg):

```bash
inkscape -w 16 -h 16 --export-filename=favicon.png --export-type=png favicon.svg

inkscape -w 64 -h 64 --export-filename=favicon-big.png --export-type=png favicon.svg
magick favicon-big.png -define icon:auto-resize=16,24,32,48,64 favicon.ico
```
