#!/bin/sh -e

cp lib_test/*.html _build/lib_test/
cd _build/lib_test
js_of_ocaml localstorage_looper.byte
js_of_ocaml localstorage_filler.byte
