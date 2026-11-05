#!/bin/sh
#
# 2ctan.sh
# Builds the CTAN archive newfloat_YYYY-MM-DD.tar.gz in the current
# directory (which must be the top level of the repository).
#
# Usage: ./2ctan.sh [--clean]
#   --clean  first run "./test.sh clean", i.e. "git clean -fdx": this removes
#            ALL untracked and ignored files from the working tree, including
#            earlier archives.
#
# The documentation in doc/*.pdf must be up to date before running this script.
# Uploading is done by hand via https://ctan.org/upload (ctanupload, below,
# no longer works).
#
# 2011-10-09: 1st version
# 2011-10-10: Log file will be copied as ".LOG" now (needs package "mmv")
# 2011-11-06: File CHANGELOG added to distribution
# 2012-03-15: Option "-p" added to "cp" command
# 2013-01-08: "-U dante" changed to "-u http://www.ctan.org/upload"
# 2013-02-03: Adapted to new SVN directory structure
# 2015-09-17: Revised, ctanupload commented out since currently-not-working
# 2019-09-09: Adapted to the "newfloat" package
# 2026-11-05: Portable (macOS): "date +%F" instead of "date --rfc-3339=date",
#             temporary directory via mktemp, "./test.sh clean" only with
#             option --clean, no macOS metadata (._* files) in the archive
#
# Needs: ctanify (TeX Live) with the Perl module File::Copy::Recursive, zip, tar

set -e

clean=false
for arg in "$@"
do
  case "$arg" in
    --clean) clean=true ;;
    *) printf '*** Invalid argument "%s". Usage: %s [--clean]\n' "$arg" "$0" >&2; exit 1 ;;
  esac
done

if [ ! -f source/newfloat.ins ]
then
  printf '*** Run this script from the top level of the repository\n' >&2
  exit 1
fi

if $clean
then
  ./test.sh clean
fi

dist_dir=$(pwd)
archive="$dist_dir/newfloat_$(date +%F).tar.gz"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/newfloat.XXXXXX")
# Remove the temporary directory on every exit, unless ctanify fails (below)
trap 'rm -fr "$temp_dir"' EXIT

# Keep macOS tar from adding ._* (AppleDouble) files to the archive
COPYFILE_DISABLE=1
export COPYFILE_DISABLE

cp -a source/*.ins source/*.dtx source/fallback "$temp_dir"
cp -a tex/*.sty "$temp_dir"
cp -a doc/*.pdf "$temp_dir"
cp -a README CHANGELOG SUMMARY "$temp_dir"
cd "$temp_dir"

# shellcheck disable=SC2035
if ctanify newfloat.ins \
	"fallback/v1.0/*.dtx=source/latex/newfloat/fallback/v1.0" \
	"fallback/v1.1/*.dtx=source/latex/newfloat/fallback/v1.1" \
	"*.sty=tex/latex/newfloat" \
	README "CHANGELOG=doc/latex/newfloat" "SUMMARY=doc/latex/newfloat" *.pdf
then
  cp -a "$temp_dir/newfloat.tar.gz" "$archive"
  cd "$dist_dir"
  rm -fr "$temp_dir"
  printf 'Created %s\n' "$archive"

#  ctanupload -l -p -u http://www.ctan.org/upload \
#    --contribution=newfloat \
#    --name "Axel Sommerfeldt" --email axel.sommerfeldt@f-m.fm \
#    --summary-file $dist_dir/SUMMARY \
#    --directory=/macros/latex/contrib/newfloat \
#    --DoNotAnnounce=0 \
#    --license=free --freeversion=lppl \
#    --file=$archive
else
  trap - EXIT
  printf '*** ctanify failed; temporary files are kept in %s\n' "$temp_dir" >&2
  exit 1
fi
