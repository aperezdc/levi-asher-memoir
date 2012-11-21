
INDEX_URL := http://www.litkicks.com/AMemoirInProgress
ALL_HTML  := $(filter-out data/index.html,$(wildcard data/*.html))
ALL_IN    := $(wildcard *.in)
ALL_INX   := $(patsubst %.in,OEBPS/%,$(ALL_IN))

ifneq (,$(strip $(ALL_HTML)))
ALL_XHTML := $(patsubst data/%.html,OEBPS/%.xhtml,$(ALL_HTML))

memoir.epub: mimetype $(ALL_INX) $(ALL_XHTML)
	zip -0 $@ mimetype
	zip -9r $@ META-INF OEBPS
endif

download: download-chapters
.PHONY: download

download-chapters: data/download-done
.PHONY: download-chapters

data/download-done:	data/chapter.urls
	mkdir -p $(@D)
	wget -q -nc -P data/ -E -i $<
	touch $@

data/chapter.urls: data/index.html
	./xtool chapter-links < $< > $@

data/index.html:
	mkdir -p $(@D)
	wget -q -O $@ $(INDEX_URL)

clean:
	$(RM) OEBPS/* memoir.epub

mrproper: clean
	$(RM) data/*
.PHONY: mrproper


### Implicit rules

OEBPS/%.xhtml: data/%.html
	mkdir -p $(@D)
	./xtool html-detox < $< > $@

OEBPS/%: %.in data/index.html
	mkdir -p $(@D)
	./xtool expand-template data/index.html < $< > $@

