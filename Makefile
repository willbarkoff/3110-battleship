ZIPFILES=*/**/*.ml* .ocamlformat .ocamlinit *.md Makefile
EXEC=./_build/default/bin/main.exe

RED=\033[0;31m
GREEN=\033[0;32m
BLUE=\033[0;34m
YELLOW=\033[1;33m
BOLD=\033[1m
CLEAR=\033[0m

HOURS_WORKED=echo "$$(cat author.ml) in (print_int hours_worked)" | ocaml  -stdin

default: play

build:
	dune build

play: build
	$(EXEC) -l

network-debug: build
	$(EXEC) -d

serve: build
	$(EXEC) 

test:
	OUNIT_CI=true dune runtest

serve-docs:
	cd ./_build/default/_doc/_html && \
	python -m SimpleHTTPServer 5000

docs:
	dune build @doc

docs-serve: docs serve-docs

docs-private:
	dune build @doc-private

docs-private-serve: docs-private serve-docs

clean:
	rm main.byte battleship.zip .merlin || true
	dune clean

zip:
	zip battleship.zip $(ZIPFILES)
	@echo "\nThe MD5 hash for submission to CMSX is $(BOLD)$(BLUE)$$(md5 -q battleship.zip)$(CLEAR)."

count:
	cloc $(ZIPFILES)

utop:
	dune utop

check: build
	@echo "\n$(GREEN)✓$(CLEAR) Your code passed $(BOLD)make build$(CLEAR), therefore, everything is working"

finalcheck: build zip check
	@echo "$(GREEN)✓$(CLEAR) Your code passed $(BOLD)make zip$(CLEAR) and is ready for submission."
	@dune exec bin/author.exe
	@echo "$(YELLOW)!$(CLEAR) Friendly reminder to tag your changes before submitted: $(BOLD)git tag -v <MS> -m <short description>$(CLEAR)"