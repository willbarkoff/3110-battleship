ZIPFILES=*/**/*.ml* .ocamlformat .ocamlinit *.md Makefile
EXEC=./_build/default/bin/main.exe


default: play

build:
	dune build

play: build
	$(EXEC) -l

serve: build
	$(EXEC) 

test:
	OUNIT_CI=true dune runtest

docs:
	dune build @doc

docs-serve:
	cd _build/default/_doc/_html && python -m SimpleHTTPServer 5000

docs-private:
	dune build @doc-private

clean:
	rm main.byte battleship.zip .merlin || true
	dune clean

zip:
	zip battleship.zip $(ZIPFILES)

count:
	cloc $(ZIPFILES)

utop:
	dune utop