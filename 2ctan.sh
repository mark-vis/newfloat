#!/bin/sh
#
# 2011-10-09: 1st version
# 2011-10-10: Log file will be copied as ".LOG" now (needs package "mmv")
# 2011-11-06: File CHANGELOG added to distribution
# 2012-03-15: Option "-p" added to "cp" command
# 2013-01-08: "-U dante" changed to "-u http://www.ctan.org/upload"
# 2013-02-03: Adapted to new SVN directory structure
# 2015-09-17: Revised, ctanupload commented out since currently-not-working
# 2019-09-09: Adapted to the "newfloat" package
#
# Needs on CentOS/Fedora: mmv perl-File-Copy-Recursive perl-HTML-FormatText* perl-WWW-Mechanize* perl-XML-TreeBuilder

set -e
dist_dir=$(pwd)
temp_dir="/tmp/newfloat"

./test.sh clean

rm -fr "$temp_dir"
mkdir "$temp_dir"
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
  cp -a "$temp_dir/newfloat.tar.gz" "$dist_dir/newfloat_$(date --rfc-3339=date).tar.gz"
  cd "$dist_dir"

#  ctanupload -l -p -u http://www.ctan.org/upload \
#    --contribution=newfloat \
#    --name "Axel Sommerfeldt" --email axel.sommerfeldt@f-m.fm \
#    --summary-file $dist_dir/doc/SUMMARY \
#    --directory=/macros/latex/contrib/newfloat \
#    --DoNotAnnounce=0 \
#    --license=free --freeversion=lppl \
#    --file=$temp_dir/newfloat.tar.gz
fi

