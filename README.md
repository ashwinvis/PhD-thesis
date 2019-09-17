# Advancements in stratified flows through simulation, experiment and open research software development

|About |   |
|------|---|
| Date and time of defence | Friday, 27 September 2019 kl 10:00 |
| Location | F3, KTH, Lindstedtsvägen 26, Stockholm |
| Supervisor | Erik Lindborg, Pierre Augier |
| PDF | [urn:nbn:se:kth:diva-256564](http://urn.kb.se/resolve?urn=urn%3Anbn%3Ase%3Akth%3Adiva-256564) |
---

## Citation

```bibtex
@phdthesis{Mohanan-advancements-2019,
  author = {Mohanan, Ashwin Vishnu},
  title = {Advancements in Stratified Flows through Simulation, Experiment and Open Research Software Development},
  year = {2019}
}
```

## Requirements

* texlive
* biblatex
* latexmk
* python>=3.6
* git-lfs
* pandoc, pandoc-crossref (included in `pandoc-requirements.txt`)

I shall also list a few applications / CLI tools which prove to be handy for
several miscalleanous uses. Not mandatory, but good to have:

* zotero
* zathura
* neovim
* vim-pandoc-syntax
* ripgrep
* rubber
* vale
* textidote
* pandoc-citeproc
* tllocalmgr
* draw.io

## Getting started

Clone and setup a python virtual environment.

    git clone --recursive https://github.com/ashwinvis/phd-thesis.git
    cd phd-thesis
    make python

## Workflows

Compile the whole thesis

    make -j

Compile a standalone PDF of a single chapter/section using pandoc

    make -j chapter_00_0_intro.pandoc.pdf

Compile a standalone PDF of all chapters in markdwon

    make -j chapters.pandoc.pdf

Watch for changes

    make watchthesis  # or watchchapter or watchchapters

Clean files

    make clean

Clean generated pdfs also

    make cleanall

## License

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img
alt="Creative Commons License" style="border-width:0"
src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work by
<span xmlns:cc="http://creativecommons.org/ns#"
property="cc:attributionName">Ashwin Vishnu Mohanan</span> is licensed under a
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative
Commons Attribution 4.0 International License</a>.
