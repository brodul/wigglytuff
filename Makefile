# Convenience makefile to build the dev env and run common commands
# Based on https://github.com/teamniteo/Makefile

.PHONY: all
all: .installed

.PHONY: install
install:
	@rm -f .installed  # force re-install
	@make .installed

.installed: pyproject.toml poetry.lock
	@echo "pyproject.toml or poetry.lock are newer than .installed, (re)installing in 1 second"
	@sleep 1
	@poetry check
	@poetry install
	@poetry run pre-commit install -f --hook-type pre-commit
	@poetry run pre-commit install -f --hook-type pre-push
	@echo "This file is used by 'make' for keeping track of last install time. If pyproject.toml or poetry.lock are newer then this file (.installed) then all 'make *' commands that depend on '.installed' know they need to run 'poetry install' first." \
		> .installed
# Run development server
.PHONY: run
run: .installed
	@FLASK_APP="wigglytuff.app" FLASK_ENV=development poetry run flask run

# Testing and linting targets
all = false

# Testing and linting targets
.PHONY: lint
lint: .installed
# 1. get all unstaged modified files
# 2. get all staged modified files
# 3. get all untracked files
# 4. run pre-commit checks on them
ifeq ($(all),true)
	@poetry run pre-commit run --hook-stage push --all-files
else
	@{ git diff --name-only ./; git diff --name-only --staged ./;git ls-files --other --exclude-standard; } \
		| sort -u | uniq | xargs poetry run pre-commit run --hook-stage push --files
endif

.PHONY: types
types: .installed
	@poetry run mypy src/
#	@cat ./typecov/linecount.txt
#	@poetry run typecov 100 ./typecov/linecount.txt

# anything, in regex-speak
filter = "."

# additional arguments for pytest
unit_test_all = "false"
ifeq ($(filter),".")
	unit_test_all = "true"
endif
ifdef path
	unit_test_all = "false"
endif
args = ""
pytest_args = -k $(filter) $(args)
coverage_args = ""
ifeq ($(unit_test_all),"true")
	coverage_args = --cov=wigglytuff --cov-branch --cov-report html --cov-report xml:cov.xml --cov-report term-missing --cov-fail-under=100
endif

.PHONY: unit
unit: .installed
# ifeq ($(unit_test_all),"true")
# 	@poetry run python -m wigglytuff.scripts.drop_tables -c etc/test.ini
# endif
ifndef path
	@poetry run pytest src/wigglytuff $(coverage_args) $(pytest_args)
else
	@poetry run pytest $(path)
endif

.PHONY: tests
tests: lint types unit

.PHONY: clean
clean:
	@rm -rf .venv/ .coverage .mypy_cache htmlcov/ htmltypecov \
		src/wigglytuff.egg-info typecov xunit.xml \
		.git/hooks/pre-commit .git/hooks/pre-push
	@rm -f .installed
