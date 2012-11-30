
INDEX_URL := http://www.litkicks.com/AMemoirInProgress
TIDY_OPT  := --output-xhtml yes \
             --add-xml-decl no \
             --add-xml-space no \
             --doctype omit \
             --drop-empty-elements yes \
             --drop-empty-paras yes \
             --drop-font-tags yes \
             --drop-proprietary-attributes yes \
             --merge-spans yes \
             --merge-divs yes \
             --show-warnings no \
             --show-errors 0 \
             --force-output yes \
             --wrap 0


ALL_HTML  := $(filter-out data/index.html,$(wildcard data/*.html))
ALL_IN    := $(wildcard *.in)
ALL_INX   := $(patsubst %.in,OEBPS/%,$(ALL_IN))
MAKEFLAGS += s


ifneq ($(strip $(IMAGES)),1)
DETOX_OPT := no-images
endif

ifneq (,$(strip $(ALL_HTML)))
ALL_XHTML := $(patsubst data/%.html,OEBPS/%.xhtml,$(ALL_HTML))
ALL_TIDY  := $(patsubst %.html,%.html.tidy,$(ALL_HTML))

all: memoir.epub

tidy: $(ALL_TIDY)

xhtml: $(ALL_XHTML)
.PHONY: xhtml

memoir.epub: mimetype $(ALL_INX) $(ALL_XHTML) data/image-download-done
	zip -0 $@.zip mimetype
	zip -9r $@.zip META-INF OEBPS
	mv $@.zip $@

.INTERMEDIATE: memoir.epub.zip
else
all: download
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
	$(RM) $(ALL_XHTML) $(ALL_INX) $(ALL_TIDY) memoir.epub

mrproper: clean
	echo "mrproper"
	$(RM) data/* OEBPS/img/*
.PHONY: mrproper

check: memoir.epub
	epubcheck $<
.PHONY: check

### Implicit rules

OEBPS/%: %.in data/index.html data/image-download-done
	echo "expand-template: $@"
	mkdir -p $(@D)
	./xtool expand-template data/index.html < $< > $@

OEBPS/%.xhtml: data/%.html
	echo "html-detox: $@"
	mkdir -p "$(@D)"
	tidy -f /dev/null -o $<.tidy $(TIDY_OPT) $< || true
	./xtool html-detox $(DETOX_OPT) < $<.tidy > $@

