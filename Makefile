# Content

AUTHOR_NAME = "Witcher"
AUTHOR_EMAIL = "witcher01@posteo.net"
SITE_TITLE = "wiredspace.de"
LOCALE = "en_GB.utf-8"

POSTS = \
	blogc \
	$(NULL)

WIKI_POSTS = \
	index \
	compsci/c/Built-in_functions_for_atomic_memory_access \
	compsci/os/memory_allocation \
	linux/arch-config \
	linux/eclim \
	linux/msmtp \
	linux/offlineimap \
	linux/tmpfs \
	linux/vim/plugins/snipmate \
	linux/vim/plugins/VimPlug \
	linux/vim/til/relative_line_numbers \
	linux/vim/til/viewing_man_pages_in_vim

PAGES = \
	index \
	blog \
	about \
	privacy \
	$(NULL)

ASSETS = \
	assets/style.css \
	$(NULL)


# Arguments

BLOGC ?= $(shell which blogc)
MKDIR ?= $(shell which mkdir)
CP ?= $(shell which cp)

OUTPUT_DIR ?= wiredspace.de
BASE_DOMAIN ?= https://wiredspace.de
BASE_URL ?= $(BASE_DOMAIN)

# day month year, hours(12):minutes AM/PM timezone
DATE_FORMAT = "%d %b %Y, %I:%M %p %Z"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D BASE_URL=$(BASE_URL) \
	$(NULL)


# Rules

# blog posts
POSTS_LIST = $(addprefix content/blog/, $(addsuffix .txt, $(POSTS)))
# pages
PAGES_LIST = $(addprefix content/, $(addsuffix .txt, $(PAGES)))
# wiki posts
WIKI_LIST = $(addprefix content/wiki/, $(addsuffix .txt, $(WIKI_POSTS)))

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/privacy.html \
	$(OUTPUT_DIR)/about.html \
	$(OUTPUT_DIR)/wiki/index.html \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/blog/, $(addsuffix .html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/wiki/, $(addsuffix .html, $(WIKI_POSTS)))

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

$(OUTPUT_DIR)/blog/%: $(POSTS_LIST) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-l \
		-t templates/main.tmpl \
		$(POSTS_LIST)

$(OUTPUT_DIR)/wiki/%: $(WIKI_LIST) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		$(patsubst $(OUTPUT_DIR)/wiki/%.html,content/wiki/%.txt,$@)

clean:
	rm -rf "$(OUTPUT_DIR)"

.PHONY: all clean
