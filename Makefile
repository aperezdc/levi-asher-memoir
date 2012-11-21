
INDEX_URL := http://www.litkicks.com/AMemoirInProgress
ALL_HTML  := $(filter-out data/index.html,$(wildcard data/*.html))
ALL_IN    := $(wildcard *.in)
ALL_INX   := $(patsubst %.in,OEBPS/%,$(ALL_IN))
MAKEFLAGS += s

ifneq (,$(strip $(ALL_HTML)))
ALL_XHTML := $(patsubst data/%.html,OEBPS/%.xhtml,$(ALL_HTML))

memoir.epub: mimetype $(ALL_INX) $(ALL_XHTML) data/image-download-done
	zip -0 $@.zip mimetype
	zip -9r $@.zip META-INF OEBPS
	mv $@.zip $@

.INTERMEDIATE: memoir.epub.zip
endif

download: download-chapters
.PHONY: download

download-chapters: data/download-done
.PHONY: download-chapters

data/image.urls: $(ALL_XHTML)
	echo "image-urls: $@"
	sed -e 's/.*<!-- img: \([^ ]\+\) -->.*/\1/p' -e d $^ > $@

data/image-download-done: data/image.urls
	mkdir -p OEBPS/img
	wget -nv -c -nc -P OEBPS/img -i $<
	touch $@

data/download-done:	data/chapter.urls
	mkdir -p $(@D)
	wget -nv -c -nc -P data/ -E -i $<
	touch $@

data/chapter.urls: data/index.html
	echo "chapter-links: $@"
	./xtool chapter-links < $< > $@

data/index.html:
	mkdir -p $(@D)
	wget -nv -c -O $@ $(INDEX_URL)

clean:
	echo "clean"
	$(RM) $(ALL_XHTML) $(ALL_INX) memoir.epub

mrproper: clean
	echo "mrproper"
	$(RM) data/* OEBPS/img/*
.PHONY: mrproper


### Implicit rules

OEBPS/%.xhtml: data/%.html
	echo "html-detox: $@"
	mkdir -p $(@D)
	./xtool html-detox < $< > $@

OEBPS/%: %.in data/index.html data/image-download-done
	echo "expand-template: $@"
	mkdir -p $(@D)
	./xtool expand-template data/index.html < $< > $@

