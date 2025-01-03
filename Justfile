set quiet

src_dir := env_var_or_default("SRC", join(justfile_directory(), "src"))

alias b   := build
alias bp  := build-presentable
alias bs  := build-slide
alias bps := build-presentable-slide
alias bsp := build-presentable-slide
alias ba  := build-all
alias bap := build-all-presentable
alias bpa := build-all-presentable

alias build-slide-presentable := build-presentable-slide
alias build-presentable-all   := build-all-presentable

[no-cd]
default:
  [ -f '{{join(".", "main.md")}}' ] && just build || just build-all

# Convert input Markdown file to PDF in output_dir
[no-cd]
build input=join(".", "main.md") output_dir="." *EXTRA_ARGS="":
  #!/usr/bin/env sh
  if [ ! -f '{{input}}' ]
  then
      echo 'Input "{{input}}" does not exist or is not a regular file!' >/dev/stderr
      exit 1
  fi
  if [ ! -d '{{output_dir}}' ]
  then
      echo 'Output directory "{{output_dir}}" does not exist or is not a directory!' >/dev/stderr
      exit 2
  fi

  output_name="{{parent_directory(absolute_path(join(invocation_directory(), input)))}}"
  cd "$output_name"
  output_name="{{absolute_path(join(output_dir, "${output_name##*/}.pdf"))}}"
  echo '"{{input}}" -> "'$output_name'"'

  pandoc --pdf-engine=xelatex -t beamer --slide-level=2       \
         --metadata-file="{{join(src_dir, "metadata.yaml")}}" \
         -s {{input}}                                         \
         -o "$output_name" {{EXTRA_ARGS}}

# Like build, but PDF has incremental lists and navigation symbols
build-presentable input=join(".", "main.md") output_dir=".": (build input output_dir "-i" "-V navigation=horizontal")

# Like build, but take slide number instead of Markdown file
[no-cd]
build-slide number output_dir="." *EXTRA_ARGS="": (_build-slide 'build' number output_dir EXTRA_ARGS)

# Like build-presentable, but take slide number instead of Markdown file
[no-cd]
build-presentable-slide number output_dir="." *EXTRA_ARGS="": (_build-slide 'build-presentable' number output_dir EXTRA_ARGS)

_build-slide type number output_dir="." *EXTRA_ARGS="":
  just {{type}} {{join(src_dir, "0*" + number + "*", "main.md")}} {{output_dir}} {{EXTRA_ARGS}}

# Build all presentations in SRC
build-all output_dir=join(justfile_directory(), "slides") *EXTRA_ARGS="":
  #!/usr/bin/env sh
  mkdir -p "{{output_dir}}"
  for presentation in {{join(src_dir, "*", "")}}
  do
      just build "${presentation}main.md" "{{output_dir}}" {{EXTRA_ARGS}} || break
  done

# Like build-all, but build-presentable is used for each slide
build-all-presentable output_dir=join(justfile_directory(), "present"): (build-all output_dir "-i" "-V navigation=horizontal")

notes:
  nvim -V1 -Es -u '~/.config/nvim/init.lua' +":Neorg export to-file ./notes/structure.md" ./notes/structure.norg
  awk '/^#/ { match($0, /^#+/); if (RLENGTH != l) c = 1; l = RLENGTH; sub(/# /, "&" ((l == 1) ? "Лекция " ++tc ")" : c++ ".") " ") } 1' ./notes/structure.md > temp
  mv temp ./notes/structure.md
  pandoc ./notes/structure.md -f markdown -t pdf --pdf-engine=xelatex -V mainfont="Liberation Serif" -V linkcolor="blue" -s -o ./notes/structure.pdf
