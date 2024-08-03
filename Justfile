alias b := build

build FORMAT="beamer":
  pandoc -t {{FORMAT}} -s slides.md -o slides.pdf

# TODO: this V (os-specific, `xdg-open` vs `open`)

# open: build
