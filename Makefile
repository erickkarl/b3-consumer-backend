PROJECT_NAME := backend
PYTHON_VERSION := 3.11.0
VENV_NAME := backend-$(PYTHON_VERSION)

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:\ /' | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

create-venv: ## install dev requirements
	python -m venv .venv

setup: ## install dependencies
	pip install -r requirements.txt

migrations-dev: ## run migrations locally
	python manage.py makemigrations

migrate-dev: ## migrate locally
	python manage.py migrate

create-superuser:
	python manage.py createsuperuser

run-dev: ## run app locally
	python manage.py runserver 8001

build: ## up all containers and building the project image
	docker-compose up -d --build

up: ## up all containers
	docker-compose up -d

down: ## down all containers
	docker-compose down
	docker-compose rm

recreate: down up ## recreate containers

migrations: ## create alembic migratrion file
	docker exec -it $(PROJECT_NAME) python manage.py makemigrations

migrate: ## run migratrion
	docker exec -it $(PROJECT_NAME) python manage.py migrate

logs: ## project logs on container
	docker logs $(PROJECT_NAME) --follow

lint: ruff

ruff:
	ruff check --fix --show-fixes .
	ruff format .

test: ## run tests
	pytest -v

test-coverage: ## run tests with coverage
	pytest -v --cov-config=setup.cfg --cov=src --cov-report=term-missing --cov-report=html --cov-report=xml --cov-fail-under=90
	sed -i 's/<source>.*<\/source>/<source>.\/<\/source>/g' coverage.xml

flake8: ## run flake8
	echo "Running flake8"
	flake8 src