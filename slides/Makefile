# Files
main:=slides
content:=$(wildcard *.pandoc.md)
pandoc_filters:=$(wildcard ./scripts/pandoc_*.py)
pandoc_lua_filters:=$(wildcard ./scripts/pandoc_*.lua)

deps:=latex/$(main).tex $(content_tex) latex/pandoc_preamble.tex ../imgs/cascade_horiz.png


# Options
pdf_viewer:=okular
# js:=s5
js:=revealjs
content_tex:=$(subst .md,.tex,$(content))

# Flags
pandoc_flags:= --natbib \
		--slide-level 3 \
		--metadata-file=scripts/meta.yml \
		$(subst ./,-F ./,$(pandoc_filters)) \
		$(subst ./,--lua-filter ./,$(pandoc_lua_filters)) \
		-F pandoc-crossref \
		--highlight-style=kate \

latexmk_flags:= -shell-escape -silent

# Env variables
# TEXINPUTS := ~/src/latex/phd-thesis/slides/:
# export TEXINPUTS

watch: $(main).pdf
	pgrep -af $(pdf_viewer) || $(pdf_viewer) $(main).pdf &
	cd latex && latexmk -pvc $(latexmk_flags) $(main).tex

pympress: $(main).pdf
	pympress -t 30 $< &

okular: $(main).pdf
	okular --presentation --noraise $< &

$(main).pdf: $(deps)
	cd latex && latexmk -silent $(main).tex

latex/$(main).aux: $(deps)
	cd latex && latexmk -pdflatex='pdflatex -draftmode -interaction=nonstopmode' $(main).tex

%.bbl: %.bcf %.aux $(BIB_FILE)
	cd latex && biber --quiet $(main)

../imgs/cascade_horiz.png: ../imgs/cascade/plot.py
	PYTHONSTARTUP=../scripts/pythonrc.py python $< horiz

check_log: $(deps)
	echo $(content)
	cd latex && rubber-info $(main)

check_fonts:
	pdffonts $(main).pdf | grep -v 'Type 1'

debug: check_log check_fonts

%.pandoc.html: %.pandoc.md $(pandoc_filters)
	pandoc \
		$(pandoc_flags) \
		--standalone \
		--self-contained \
		-t $(js) \
		$< -o $@

%.pandoc.tex: %.pandoc.md $(pandoc_filters)
	pandoc \
		$(pandoc_flags) \
		-t beamer \
		$< -o $@

preamble.tex: $(content)
	pandoc \
		$(pandoc_flags) \
		-t beamer \
		--standalone \
		$< -o $@

clean:
	cd latex && latexmk -c $(main).tex
	rm -f $(content_tex)
	rm -f preamble.tex

cleanall: clean
	cd latex && latexmk -C $(main).tex
