SASS_DIR = priv/sass
DOCS_ROOT = $(ROOT_DIR)/docs
DOCS_STABLE_BUILD_DIR = $(DOCS_ROOT)/current
DOCS_DEV_BUILD_DIR = $(DOCS_ROOT)/dev
SASS = sass --no-cache -f --trace
SASS_MIN = $(SASS) --style compressed

sass:
	sudo gem update --system
	sudo gem install sass

css:
	@echo "\nGenerating minimized and regular versions of CSS files for $(DEPLOYMENT) ..."
	@echo
	@$(SASS_MIN) $(SASS_DIR)/lfe-$(DEPLOYMENT).scss \
		$(DOCS_ROOT)/$(DEPLOYMENT)/css/bootstrap-min.css
	@$(SASS) $(SASS_DIR)/lfe-$(DEPLOYMENT).scss \
		$(DOCS_ROOT)/$(DEPLOYMENT)/css/bootstrap.css
	@echo "Done.\n"

css-dev: DEPLOYMENT = dev
css-dev: css

css-stable: DEPLOYMENT = current
css-stable: css

css-1.3: DEPLOYMENT = v1.3
css-1.3: css

docs-dev: clean compile css-dev
	@echo "\nBuilding docs ..."
	@echo
	@ERL_LIBS=$(ERL_LIBS) erl -s docs -s docs-gen run-dev -noshell -eval 'init:stop()'

docs-stable: clean compile css-stable
	@echo "\nBuilding docs ..."
	@echo
	@ERL_LIBS=$(ERL_LIBS) erl -s docs -s docs-gen run -noshell -eval 'init:stop()'

docs-only:
	@echo "\nBuilding docs ..."
	@echo
	@ERL_LIBS=$(ERL_LIBS) erl -s docs -s docs gen-content -noshell -eval 'init:stop()'

devdocs: docs
	@echo "\nRunning docs server on http://$(LOCAL_DOCS_HOST):$(LOCAL_DOCS_PORT) ... (To quit, hit ^c twice)"
	@echo
	@ERL_LIBS=$(ERL_LIBS) erl -s docs -s docs gen-content -s docs httpd -noshell

contributors:
	git log --pretty=format:"%an"|sort -u

devcss:
	@echo "\nRunning docs server on http://$(LOCAL_DOCS_HOST):$(LOCAL_DOCS_PORT) ... (To quit, hit ^c twice)"
	@echo
	@sass --watch $(SASS_DIR)/lfe-theme.scss:$(CSS_BUILD_DIR)/bootstrap-min.css &
	@ERL_LIBS=$(ERL_LIBS) erl -s docs -s docs gen-content -s docs httpd -noshell

.PHONY: docs