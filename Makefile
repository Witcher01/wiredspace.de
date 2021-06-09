# Content

AUTHOR_NAME = "Witcher"
AUTHOR_EMAIL = "witcher@memeware.net"
SITE_TITLE = "wiredspace.de"
LOCALE = "en_GB.utf-8"

POSTS_PER_PAGE = 1
POSTS_PER_PAGE_ATOM = 10

POSTS = \
	blogc \
	blogc_pagination \
	discord_go_bot \
	$(NULL)

WIKI_POSTS = \
	index \
	compsci/c/Built-in_functions_for_atomic_memory_access \
	compsci/os/memory_allocation \
	linux/arch-config \
	linux/eclim \
	linux/msmtp \
	linux/offlineimap \
	linux/mbsync \
	linux/tmpfs \
	linux/vim/plugins/snipmate \
	linux/vim/plugins/VimPlug \
	linux/vim/til/relative_line_numbers \
	linux/vim/til/viewing_man_pages_in_vim

PAGES = \
	index \
	about \
	privacy \
	$(NULL)

ASSETS = \
	assets/style.css \
	assets/bulma/css/bulma.css \
	$(NULL)


# Arguments

BLOGC ?= $(shell which blogc)
BLOGC_RUNSERVER ?= $(shell which blogc-runserver 2> /dev/null)
MKDIR ?= $(shell which mkdir)
CP ?= $(shell which cp)

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080

OUTPUT_DIR ?= wiredspace.de
BASE_DOMAIN ?= https://wiredspace.de
BASE_URL ?= $(BASE_DOMAIN)

# day month year, hours(12):minutes AM/PM timezone
DATE_FORMAT = "%d %b %Y, %I:%M %p %Z"
DATE_FORMAT_RFC822 = "%a, %d %b %y %T %z"

RSS_FILE_LOCATION = "blog/blog.rss"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D BASE_URL=$(BASE_URL) \
		-D RSS_FILE_LOCATION=$(RSS_FILE_LOCATION) \
	$(NULL)


# Rules

# blog posts
POSTS_LIST = $(addprefix content/blog/, $(addsuffix .txt, $(POSTS)))
# pages
PAGES_LIST = $(addprefix content/, $(addsuffix .txt, $(PAGES)))
# wiki posts
WIKI_LIST = $(addprefix content/wiki/, $(addsuffix .txt, $(WIKI_POSTS)))

LAST_PAGE = $(shell $(BLOGC_COMMAND) \
	-D FILTER_PAGE=1 \
	-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
	-p LAST_PAGE \
	-l \
	$(POSTS_LIST))

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/privacy.html \
	$(OUTPUT_DIR)/about.html \
	$(OUTPUT_DIR)/wiki/index.html \
	$(OUTPUT_DIR)/blog/blog.rss \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/wiki/, $(addsuffix .html, $(WIKI_POSTS))) \
	$(addprefix $(OUTPUT_DIR)/blog/post/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/blog/page/, $(addsuffix /index.html, \
		$(shell for i in $(shell seq 1 $(LAST_PAGE)); do echo $$i; done)))

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(MKDIR) -p $(dir $@) && \
		$(CP) $< $@

$(OUTPUT_DIR)/index.html: templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		content/index.txt

$(OUTPUT_DIR)/privacy.html: templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		content/privacy.txt

$(OUTPUT_DIR)/about.html: templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		content/about.txt

$(OUTPUT_DIR)/wiki/index.html: templates/main.tmpl Makefile
	$(MKDIR) -p $(dir $@) && \
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		content/wiki/index.txt

$(OUTPUT_DIR)/blog/page/%/index.html: $(POSTS_LIST) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/blog/page/,,' -e 's,/index\.html$$,,') \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D FILTER_REVERSE=1 \
		-D IS_POST=1 \
		-D LAST_PAGE=$(LAST_PAGE) \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(POSTS_LIST)

$(OUTPUT_DIR)/blog/post/%/index.html: content/blog/%.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D IS_POST=1 \
		-D LAST_PAGE=$(LAST_PAGE) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/blog/blog.rss: $(POSTS_LIST) templates/rss.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_RFC822) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/rss.tmpl \
		$(POSTS_LIST)

$(OUTPUT_DIR)/wiki/%: $(WIKI_LIST) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		$(patsubst $(OUTPUT_DIR)/wiki/%.html,content/wiki/%.txt,$@)

clean:
	rm -rf "$(OUTPUT_DIR)"

ifneq ($(BLOGC_RUNSERVER),)
.PHONY: serve
serve: all
		$(BLOGC_RUNSERVER) \
		-t $(BLOGC_RUNSERVER_HOST) \
		-p $(BLOGC_RUNSERVER_PORT) \
		$(OUTPUT_DIR)
endif

.PHONY: all clean
