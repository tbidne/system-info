#!/bin/sh

mkdir -p ./docs
rm -rf ./docs/*
cabal haddock --haddock-hyperlink-source
cp -r dist-newstyle/build/x86_64-linux/ghc-8.10.7/system-info-0.1.0.0/doc/html/system-info/* ./docs