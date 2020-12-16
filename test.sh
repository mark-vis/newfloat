#!/bin/bash

# test.sh
# Tests the newfloat package

# Author: Axel Sommerfeldt (axel.sommerfeldt@f-m.fm)
# URL:    https://gitlab.com/axelsommerfeldt/caption
# Date:   2020-12-16

source ./test-lib.sh

disable test/documentclass/amsbook.tex # TODO
disable test/documentclass/smfbook.tex # TODO
disable test/misc/redefine_figure.tex  # Should issue error

main "$@"

