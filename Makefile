#------------------------------------------------------------------------------
# This is a makefile tailored to work with the latex documents for the
# Licentiate and PhD thesis (MechThesis).
#------------------------------------------------------------------------------


# Variables:
#
kappa := overview
main := thesis
chapter := chapter_01_0_intro
paper := paper_0*
TEMPLATE_DIR := ./templates/mechthesis/

TEX := pdflatex
DRAFT_FLAGS := -draftmode -interaction=nonstopmode -shell-escape
FINAL_FLAGS := -interaction=nonstopmode -shell-escape
ifdef CI
TEX := texliveonfly --terminal_only -f
DRAFT_FLAGS := -a "$(DRAFT_FLAGS)"
FINAL_FLAGS := -a "$(FINAL_FLAGS)"
endif

VIM := nvim
VIM_FLAGS := +'set backupcopy=yes'

BIB := biber
BIB_FLAGS :=
BIB_FILE := $(main).bib

red:="\033[0;31m"
end:="\033[0m"

define cprint =
	@echo -e $(red)[$(shell date +'%H.%M.%S')] $(1)$(end)
endef

define watchdog =
	@echo -e "Execute watchdog: on pattern $(1): run $(2)"
	nohup watchmedo shell-command --patterns=$(1) --command=$(2) --drop 2>watch.log&
endef

define pandoc_standalone =
	@pandoc \
		$(PANDOC_FILTERS) \
		-F pandoc-crossref \
		-F pandoc-citeproc \
		--bibliography $(BIB_FILE) \
		--csl templates/journal-of-fluid-mechanics.csl \
		--standalone \
		--from markdown+table_captions \
		--metadata-file=pandoc-meta.yml \
		--number-sections \
		$(1) -o $(2)
endef

define fix_toc =
	@sed -i 's/\\000t\\000o\\000P\\000a\\000p\\000e\\000r/\\000P\\000a\\000p\\000e\\000r/g' thesis.out
endef

# ifndef CI
REDIRECT := | tail -n 2
# else
# REDIRECT := # no redirect
# endif

RUBBER_INFO := $(shell command -v rubber-info 2> /dev/null)

# Dependencies:
#
TEMPLATE_PAPER = templates/template_mechthesis_paper.tex
META_PAPER = $(wildcard $(paper)/paper.yml)
SRCS_PAPER = $(subst /,/paper.tex,$(wildcard $(paper)/))
SRCS = packages.tex         \
       commands.tex         \
       frontmatter.tex      \
       acknowledgements.md  \
       $(kappa).tex         \
       $(main).tex          \
       $(SRCS_PAPER)

# Template and BibTeX dependencies
#
DEPS = $(TEMPLATE_DIR)/MechThesis.cls       \
       $(TEMPLATE_DIR)/jfm.bst              \
       $(BIB_FILE)

AUXS = $(kappa).aux \
       $(subst /,/paper.aux,$(wildcard $(paper)/)) \
       $(main).toc  \
       $(main).glo \
       $(main).ist
       # $(main).aux \

BBLS = $(main).bbl \
       $(main).bcf

IMGS = imgs/cascade.pdf \
	imgs/dependency.pdf \
	imgs/spectral_flux.pdf

MKDWN = $(sort $(wildcard chapter*.md))
MKDWN2TEX = $(subst .md,.latex,$(MKDWN))
MKDWN2PANDOCTEX = $(subst .md,.pandoc.tex,$(MKDWN))

PANDOC_FILTERS = $(subst ./,-F ./,$(wildcard ./scripts/pandoc_*.py))
# Rules:
#
.PHONY: default all clean clean_papers clean_thesis clean_minted cleanall vimtex doit red end
.NOPARALLEL: $(main).pdf $(main).bbl $(main).gls log watch

all: glossary.tex log
#
$(main).pdf: $(SRCS) $(DEPS) $(AUXS) $(BBLS) $(main).gls
	$(call cprint,"building $@ with $(TEX)")
	$(TEX) $(FINAL_FLAGS) $(main) $(REDIRECT)
	$(call fix_toc)

$(AUXS): $(main).aux

$(main).aux: $(SRCS) $(DEPS) $(MKDWN2TEX) $(IMGS)
	$(call cprint,"building $@ with $(TEX)")
	$(TEX) $(DRAFT_FLAGS) $(main) $(REDIRECT)
	$(call fix_toc)

$(main).gls: $(AUXS) $(BBLS) glossary.tex
	$(call cprint,"building $@ with makeglossaries")
	@makeglossaries -t $(main).log $(main)

%.bcf: %.aux
	$(call cprint,"building $@ with $<")

%.bbl: %.bcf %.aux $(BIB_FILE)
	$(call cprint,"building $@ with $(BIB) on $(BIB_FILE)")
	@$(BIB) $(BIB_FLAGS) $(main) $(REDIRECT)

%.tex: %.yml $(TEMPLATE_PAPER) scripts/render_paper_yml.py
	$(call cprint,"building $@ with python $(TEMPLATE_PAPER)")
	@python scripts/render_paper_yml.py $< $(TEMPLATE_PAPER)

glossary.tex: glossary.yml scripts/render_glossary_yml.py
	$(call cprint,"building $@ with python scripts/render_glossary_yml.py")
	@python scripts/render_glossary_yml.py $< templates/template_glossary.tex

imgs/%.pdf: imgs/%/plot.py
	$(call cprint,"building $@ with $<")
	PYTHONSTARTUP=scripts/pythonrc.py python $<

chapter_%.md: $(IMGS)
	$(call cprint,"ensuring $^ required for $@")

# MKDWN2TEX
chapter_%.latex: chapter_%.md
	$(call cprint,"building $@ with pandoc $<")
	@pandoc \
		$(PANDOC_FILTERS) \
		-F pandoc-crossref \
		--natbib \
		$< -o $@

chapter_%.pandoc.tex: chapter_%.md
	$(call cprint,"building $@ with pandoc $<")
	$(call pandoc_standalone,$<,$@)

chapters.pandoc.tex: $(MKDWN)
	$(call cprint,"building $@ with pandoc $^")
	$(call pandoc_standalone,$^,$@)

chapter_%.pandoc.pdf: chapter_%.pandoc.tex
	$(call cprint,"building $@ with latexmk")
	@latexmk -silent -use-make -pdf $<

chapters.pandoc.pdf: chapters.pandoc.tex
	$(call cprint,"building $@ with latexmk")
	@latexmk -silent -use-make -pdf $<

$(BIB_FILE):
	$(call cprint,"building $@ with python scripts/get_bib.py")
	@python scripts/get_bib.py

log: $(main).pdf
	$(call cprint,"printing $@")
ifndef RUBBER_INFO
	cat $(main).log
else
	rubber-info $(main).tex
endif

clean: clean_papers clean_thesis
	$(call cprint,"basic cleaning done")

cleanall: clean
	$(call cprint,"cleaning generated documents")
	@rm -f  *.{ps,dvi,pdf,pandoc.pdf}
	@rm -f chapter*.latex
	@rm -f paper*/paper.tex

clean_minted:
	$(call cprint,"cleaning minted")
	@rm -rf _minted-$(main) $(paper)/_minted-*

clean_thesis:
	$(call cprint,"cleaning thesis")
	@rm -f *.{aux,toc,log,out,bbl,bcf,blg,pls,psm,synctex.gz,fls,fdb_latexmk,run.xml,gl?,ist,pandoc.tex,acn,acr}

clean_papers:
	$(call cprint,"cleaning papers")
	@rm -f paper*/*.{aux,bbl,blg,fls,fdb_latexmk,log,out,synctex.gz}

todo:
	@# grep -r --color=tty '%.*[Tt][Oo][Dd][Oo]:'
	@# ack --nomake '[Tt][Oo][Dd][Oo]:'
	@rg -Tmake '[Tt][Oo][Dd][Oo]:'

opentex:
	$(VIM) $(chapter).tex $(VIM_FLAGS) 2> /dev/null &

openmkdwn:
	$(VIM) $(chapter).md $(VIM_FLAGS)

openchapter: $(chapter).pandoc.pdf
	zathura $< 2> /dev/null &

openchapters: chapters.pandoc.pdf
	zathura $< 2> /dev/null &

openthesis: $(main).pdf
	zathura $< 2> /dev/null &

watchchapter:
	$(call cprint,"watching for changes")
	$(call watchdog,"*.md",'make $(chapter).pandoc.pdf $(chapter).latex')

watchchapters:
	$(call cprint,"watching for changes")
	$(call watchdog,"*.md",'make chapters.pandoc.pdf')

watchthesis:
	$(call cprint,"watching for changes")
	$(call watchdog,"*.tex",'make -j')

watchstop:
	@pgrep -f watchmedo | xargs kill

# doit: openthesis watchthesis opentex
# doit: $(chapter).pandoc.pdf openchapter watchchapter openmkdwn
doit: openchapters watchchapters openmkdwn

%.txt: %.in
	pip-compile $<

pyenv:
	python -m venv $@

pyrequirements: requirements.txt dev-requirements.txt pandoc-requirements.txt
	bash -c 'source pyenv/bin/activate; pip install pip-tools; pip-sync $^'

python: pyenv pyrequirements
