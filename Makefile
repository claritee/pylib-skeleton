# -----------------------------------------------------------------------------
# Dan's Ultimate Makefile for Python Libraries
# author: Daniel Kovacs <dkovacs@ebay.com>
# version: 2.5
# supported: virtualenv, docker, jupyter, asset downloading
# 
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# package config
# -----------------------------------------------------------------------------

PACKAGE_HOME := $(PWD)
PACKAGE_NAME := mypackage
PACAKGE_SOURCES := $(PACKAGE_HOME)/$(PACKAGE_NAME)
PACKAGE_TEST := $(PACKAGE_HOME)/test
PACKAGE_BIN := $(PACKAGE_HOME)/bin
PACKAGE_ENVIRONMENT_FILE := .environment


# -----------------------------------------------------------------------------
# build config
# -----------------------------------------------------------------------------

BUILD_DIST_DIR := $(PACKAGE_HOME)/dist
BUILD_TARGET := sdist
BUILD_ARGS := 


# -----------------------------------------------------------------------------
# virtualenv config
# -----------------------------------------------------------------------------

VIRTUALENV_DIR := .virtualenv
VIRTUALENV_HOME := $(PACKAGE_HOME)/$(VIRTUALENV_DIR)
VIRTUALENV_ACTIVATE := $(VIRTUALENV_HOME)/bin/activate


# -----------------------------------------------------------------------------
# docker config
# -----------------------------------------------------------------------------

DOCKER_IMAGE_LOCK := $(PACKAGE_HOME)/.docker-image
DOCKER_IMAGE_TAG := "ecg/harx-notebook"
DOCKER_PORT := 8888
# DOCKER_ARGS=-p $(DOCKER_PORT):$(DOCKER_PORT) -v $(PWD)/$(PACKAGE_NAME):/opt/conda/lib/python3.6/site-packages/$(PACKAGE_NAME) -v $(PWD)/notebooks:/home/jovyan/work $(DOCKER_IMAGE_TAG) start-notebook.sh --NotebookApp.token=''
DOCKER_ARGS := -p $(DOCKER_PORT):$(DOCKER_PORT) -v $(PWD)/$(PACKAGE_NAME):/opt/conda/envs/python2/lib/python2.7/site-packages/$(PACKAGE_NAME) -v $(PWD)/notebooks:/home/jovyan/work -v $(PWD)/data:/home/jovyan/data $(DOCKER_IMAGE_TAG) start-notebook.sh --NotebookApp.token=''


# -----------------------------------------------------------------------------
# assets config
# -----------------------------------------------------------------------------

ASSETS_HOME=./assets


# -----------------------------------------------------------------------
# define checkenv-start-validation
# -----------------------------------------------------------------------

define checkenv-start-validation
	@echo "checking environment...."
	@rm -f $(PACKAGE_ENVIRONMENT_FILE)
endef


# -----------------------------------------------------------------------
# define checkenv-command
# -----------------------------------------------------------------------

define checkenv-command
	@printf "checking $(1)..." && (type $(1) >> $(PACKAGE_ENVIRONMENT_FILE) 2>&1 && echo "ok") || (echo "error: $(1) not found" >> $(PACKAGE_ENVIRONMENT_FILE) && echo "NOT FOUND" && true)
endef


# -----------------------------------------------------------------------
# define checkenv-validate
# -----------------------------------------------------------------------

define checkenv-validate
	@(grep error $(PACKAGE_ENVIRONMENT_FILE) > /dev/null 2>&1 && rm -f $(PACKAGE_ENVIRONMENT_FILE) || true)
	@( [ -f $(PACKAGE_ENVIRONMENT_FILE) ] || (echo "error: invalid environment configuration.\n\nPlease install the missing packages listed above.\n" && false) )
endef


# -----------------------------------------------------------------------
# target: _recheckenv
# -----------------------------------------------------------------------

_recheckenv::
	@rm -f $(PACKAGE_ENVIRONMENT_FILE)


# -----------------------------------------------------------------------
# target: checkenv
# -----------------------------------------------------------------------

.PHONY: checkenv
checkenv:: _recheckenv $(PACKAGE_ENVIRONMENT_FILE)


# -----------------------------------------------------------------------
# target: $(PACKAGE_ENVIRONMENT_FILE)
# -----------------------------------------------------------------------

$(PACKAGE_ENVIRONMENT_FILE):: Makefile
	$(call checkenv-start-validation)
	$(call checkenv-command,git)
	$(call checkenv-command,python)
	$(call checkenv-command,pip)
	$(call checkenv-command,virtualenv)
	# $(call checkenv-command,wget)
	$(call checkenv-command,docker)
	$(call checkenv-validate)


# -----------------------------------------------------------------------------
# clean
# -----------------------------------------------------------------------------

.PHONY:clean
clean::
	rm -rf $(PACKAGE_ENVIRONMENT_FILE) $(VIRTUALENV_HOME) $(ASSETS_HOME) activate build dist .cache .eggs .tmp
	find . -name "*.pyc" -exec rm -rf {} \; || true
	find . -name "__pycache__" -exec rm -rf {} \; || true


# -----------------------------------------------------------------------------
# .virtualenv
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME): requirements.txt $(PACKAGE_ENVIRONMENT_FILE) 
	virtualenv $@
	ln -sf $(VIRTUALENV_ACTIVATE) .


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)/deps
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/deps: requirements.txt $(VIRTUALENV_HOME)
	source activate && pip install -r $<
	touch $@


# -----------------------------------------------------------------------------
# deps
# -----------------------------------------------------------------------------

.PHONY: deps
deps: $(VIRTUALENV_HOME)/deps


# -----------------------------------------------------------------------------
# $(VIRTUALENV_DIR)/test-deps
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/test-deps: requirements-test.txt $(VIRTUALENV_HOME)/deps
	source activate && pip install -r $<
	touch $@


# -----------------------------------------------------------------------------
# test-deps
# -----------------------------------------------------------------------------

.PHONY: test-deps
test-deps: $(VIRTUALENV_HOME)/test-deps


# -----------------------------------------------------------------------
# target: %-test
# -----------------------------------------------------------------------

test-%:: $(PACKAGE_TEST)/%_test.py test-deps
	source activate && py.test -s $<


# -----------------------------------------------------------------------
# target: test-modules
# -----------------------------------------------------------------------

.PHONY: test-modules
test-modules:: test-deps
	source activate && ./setup.py test --addopts $(PACAKGE_SOURCES)/

# -----------------------------------------------------------------------
# target: test-e2e
# -----------------------------------------------------------------------

.PHONY: test-e2e
test-e2e:: test-deps
	source activate && ./setup.py test --addopts test/


# -----------------------------------------------------------------------
# target: test
# -----------------------------------------------------------------------

.PHONY: test
test:: test-deps
	source activate && ./setup.py test --addopts "$(PACAKGE_SOURCES)/ test/"


# -----------------------------------------------------------------------
# target: install
# -----------------------------------------------------------------------

install:: $(SOURCES)
	./setup.py install


# -----------------------------------------------------------------------
# target: build
# -----------------------------------------------------------------------

build:: $(SOURCES)
	./setup.py $(BUILD_TARGET) $(BUILD_ARGS)


# -----------------------------------------------------------------------------
# shell
# -----------------------------------------------------------------------------

shell: deps
	source activate && python -i shell.py


# -----------------------------------------------------------------------------
# $(DOCKER_IMAGE_LOCK)
# -----------------------------------------------------------------------------
$(DOCKER_IMAGE_LOCK): Dockerfile requirements.txt
	docker build -t $(DOCKER_IMAGE_TAG) .
	touch $@


# -----------------------------------------------------------------------------
# docker-image
# -----------------------------------------------------------------------------

docker-image: $(DOCKER_IMAGE_LOCK)

# -----------------------------------------------------------------------------
# clear-docker-image
# -----------------------------------------------------------------------------

.PHONY: clear-docker-image
clear-docker-image:
	docker image rm $(DOCKER_IMAGE_TAG)


# -----------------------------------------------------------------------------
# notebook
# -----------------------------------------------------------------------------

notebook: $(DOCKER_IMAGE_LOCK)
	docker run -d $(DOCKER_ARGS)
	open http://localhost:$(DOCKER_PORT)/notebooks/work/demo.ipynb


# -----------------------------------------------------------------------------
# notebook
# -----------------------------------------------------------------------------

notebook-fg: $(DOCKER_IMAGE_LOCK)
	(sleep 3 && open http://localhost:$(DOCKER_PORT)/notebooks/work/demo.ipynb)&
	docker run -it $(DOCKER_ARGS)



# -----------------------------------------------------------------------------
# $(ASSETS_HOME)
# -----------------------------------------------------------------------------

$(ASSETS_HOME): assets.txt $(PACKAGE_ENVIRONMENT_FILE)
	mkdir -p $@
	wget --no-clobber -i $< -P $@
	ls -lah $@

assets: $(ASSETS_HOME)


# -----------------------------------------------------------------------------
# setup
# -----------------------------------------------------------------------------

.PHONY: setup
setup: deps # assets  uncomment assets to include asset downloading in setup

