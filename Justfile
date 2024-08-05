alias b := build

build FORMAT="beamer":
  pandoc -t {{FORMAT}} -s slides.md -o slides.pdf

notes:
  nvim -V1 -Es -u '~/.config/nvim/init.lua' +":Neorg export to-file ./notes/structure.md" ./notes/structure.norg
  awk '/^#/ { match($0, /^#+/); if (RLENGTH != l) c = 1; l = RLENGTH; sub(/# /, "&" ((l == 1) ? "Лекция " ++tc ")" : c++ ".") " ") } 1' ./notes/structure.md > temp
  mv temp ./notes/structure.md
  pandoc ./notes/structure.md -f markdown -t pdf --pdf-engine=xelatex -V mainfont="Liberation Serif" -V linkcolor="blue" -s -o ./notes/structure.pdf

# TODO: this V (os-specific, `xdg-open` vs `open`)

# open: build
