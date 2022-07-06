# core

.PHONY: build
build:
	cabal build all

.PHONY: clean
clean:
	cabal clean

.PHONY: test
test:
	RUN_DOCTEST=1 cabal test

.PHONY: doctest
doctest:
	RUN_DOCTEST=1 cabal test doctest

.PHONY: unit
unit:
	cabal test unit

.PHONY: functional
functional:
	RUN_FUNCTIONAL=1 cabal test functional

.PHONY: repl
repl:
	cabal repl

.PHONY: watch
watch:
	ghcid --command "cabal repl"

# ci

.PHONY: cic
cic: formatc lintc haddockc

.PHONY: ci
ci: format lint

# formatting

.PHONY: formatc
formatc: cabalfmtc hsformatc nixpkgsfmtc

.PHONY: format
format: cabalfmt hsformat nixpkgsfmt

.PHONY: hsformat
hsformat:
	nix run github:tbidne/nix-hs-tools/0.6#ormolu -- --mode inplace

.PHONY: hsformatc
hsformatc:
	nix run github:tbidne/nix-hs-tools/0.6#ormolu -- --mode check

.PHONY: cabalfmt
cabalfmt:
	nix run github:tbidne/nix-hs-tools/0.6#cabal-fmt -- --inplace

.PHONY: cabalfmtc
cabalfmtc:
	nix run github:tbidne/nix-hs-tools/0.6#cabal-fmt -- --check

.PHONY: nixpkgsfmt
nixpkgsfmt:
	nix run github:tbidne/nix-hs-tools/0.6#nixpkgs-fmt

.PHONY: nixpkgsfmtc
nixpkgsfmtc:
	nix run github:tbidne/nix-hs-tools/0.6#nixpkgs-fmt -- --check

# linting

.PHONY: lint
lint:
	nix run github:tbidne/nix-hs-tools/0.6#hlint -- --refact

.PHONY: lintc
lintc:
	nix run github:tbidne/nix-hs-tools/0.6#hlint

.PHONY: haddock
haddock:
	cabal haddock --haddock-hyperlink-source --haddock-quickjump ;\
	mkdir -p docs/ ;\
	find docs/ -type f | xargs -I % sh -c "rm -r %" ;\
	cp -r dist-newstyle/build/x86_64-linux/ghc-9.2.2/pythia-0.1/noopt/doc/html/pythia/* docs/

.PHONY: haddockc
haddockc:
	nix run github:tbidne/nix-hs-tools/0.6#haddock-cov -- . -x Pythia.Prelude

.PHONY: hackage
hackage:
	cabal sdist ;\
	cabal haddock --haddock-for-hackage --enable-doc