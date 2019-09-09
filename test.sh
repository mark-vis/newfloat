#!/bin/bash

# test.sh
# Author: Axel Sommerfeldt (axel.sommerfeldt@f-m.fm)
# URL:    https://gitlab.com/axelsommerfeldt/newfloat

# shellcheck disable=SC2103,SC2164

help=false
if [[ $1 == "-?" || $1 == "--help" ]]
then
  printf "Syntax: ./test.sh [<sub-directory>]\n"
  printf "where <sub-directory> is either:\n"
  printf "  all   - compiles all test files (default)\n"
  printf "  clean - remove intermediate files only\n"
  printf "or one of:\n "
  help=true # print list of sub-directories without processing them
fi

basedir=$(pwd)
logfile="$basedir/test.log"

# Store argument as $dironly (default is "all" -> "*")
dironly=${1:-all}
if [[ $dironly == "all" ]]; then dironly="*"; fi
dirfound=false  # no matching directory was found so far

cleanup()
{
  # Remove interim files
  # Note: This removes all unstaged (new) files as well.
  git clean -fdx -e source/ltxdoc.cfg
}

compile_all()
{
  [[ -d $1 ]] || return # Process directories only

  if $help
  then
    # In help mode only print the sub-directory name
    printf " $1"
  # shellcheck disable=SC2053
  elif [[ $1 == $dironly ]]
  then
    dirfound=true # matching directory found

    # Compile all files in the given directory
    cd "$1"
    cp -a "$basedir"/tex/*.sty .

    shopt -s nullglob
    files=(*.dtx *.ltx *.tex)
    for file in "${files[@]}"
    do
      compile "$1" "$file"
    done

    cd ..
  fi
}

compile()
{
  # Skip example documents which purpose is to produce an error
  # (or cannot be compiled for a different reason)
# [[ $1 == "gitlab"      && $2 == "20xx-xx-xx.tex" ]] && return  # <Enter the reason here>

  # Compile document three times (so interim files will be used)
  pdflatex "$2" || failed "$1" "$2"
  pdflatex "$2" || failed "$1" "$2"
  pdflatex "$2" || failed "$1" "$2"
  printf "Compiling %s/%s passed.\n" "$1" "$2" | tee -a "$logfile"
}

failed()
{
  # Print error message and exit
  printf "\n*** Compiling %s/%s failed.\n" "$1" "$2" | tee -a "$logfile"
  exit 1
}

# Do not remove intermediate files in help mode
if ! $help
then
  # Remove intermediate files
  cleanup
  [[ $dironly != "clean" ]] || exit
fi

# Compile all package documentations
compile_all "source"

# Compile all test documents
#cd test
#dirs=(*)
#for dir in "${dirs[@]}"
#do
#  compile_all "$dir"
#done
#cd ..

# Compile all issue documents
cd issues
dirs=(*)
for dir in "${dirs[@]}"
do
  compile_all "$dir"
done
cd ..

# Print test result
if $help
then
  printf "\n"
elif $dirfound
then
  printf "\nThat's all, folks!\n"
else
  printf "*** No sub-directory '%s' found.\n" "$dironly" >&2
fi

