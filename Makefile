# —— Inspired by ———————————————————————————————————————————————————————————————
# https://www.strangebuzz.com/en/snippets/the-perfect-makefile-for-symfony
# http://fabien.potencier.org/symfony4-best-practices.html
# https://speakerdeck.com/mykiwi/outils-pour-ameliorer-la-vie-des-developpeurs-symfony?slide=47
# https://blog.theodo.fr/2018/05/why-you-need-a-makefile-on-your-project/

# Setup ————————————————————————————————————————————————————————————————————————
PROJECT       = intranet
DOCKER        = docker
DOCKER_COMP   = docker-compose
DOCKER_EXEC   = docker exec
DB_CONTAINER  = intranet_db
PHP_CONTAINER = intranet_php
SYMFONY       = $(DOCKER) exec -w /srv/app $(PHP_CONTAINER) bin/console
COMPOSER      = $(DOCKER) exec -w /srv/app $(PHP_CONTAINER) composer
.DEFAULT_GOAL = help

## —— intranet Makefile ——————————————————————————————————————-

## —— Init 🌟️ ————————————————————————————————————————————————————————————
init: down init-network env up install fix-perms check-db-container db-init npm-ci npm-dev## Project initialization! Just do it! (Long story... You can get a coffee! ☕ )

reset: down init-network env up fix-perms install check-db-container db-init npm-ci npm-dev ## Project reset! If you have already init the project

## —— Docker 🐳 ————————————————————————————————————————————————————————————
init-network: ## Create intranet docker network if not exists
	@$(DOCKER) network create intranet_network || echo "Don't worry! We can continue..."

env: ## Create .env file
	\cp -r .env .env.local
php: ## Enter PHP container as root
	@echo "Entering PHP container..."
	$(DOCKER_EXEC) -it $(PHP_CONTAINER) /bin/sh

mysql: ## Enter MySQL container as root
	@echo "Entering MySQL container..."
	$(DOCKER_EXEC) -it $(DB_CONTAINER) /bin/bash

up: ## Start only the required containers (PHP, Nginx, MySQL, Redis, RabbitMQ)
	$(DOCKER_COMP) up -d --build

down: ## Stop the required containers (PHP, Nginx, MySQL, Redis, RabbitMQ)
	$(DOCKER_COMP) down --remove-orphans

## —— Composer 🧙️ ————————————————————————————————————————————————————————————
install: composer.lock ## Install vendors according to the current composer.lock file
	$(COMPOSER) install --no-progress --no-suggest --prefer-dist --optimize-autoloader

update: composer.json ## Update vendors according to the composer.json file
	$(COMPOSER) update

## —— Database 🗄️️ ————————————————————————————————————————————————————————————
check-db-container: ## Check db container is up
	@$(DOCKER) info > /dev/null 2>&1 # Docker is up
	$(DOCKER) inspect --format "{{json .State.Status }}" $(DB_CONTAINER) # Db container is running
	sleep 10 # Waiting until Db container is 100% ready.

db-init: db-clear-meta db-migrate db-validate ## Build the DB from pre-prod dump, control the schema validity and check the migration status (Long story... You can get a coffee! ☕ )

db-validate: ## Compare database schema with the current mapping file
	$(SYMFONY) doctrine:schema:validate

db-migrate: ## Execute doctrine migrations
	$(SYMFONY) doctrine:migrations:migrate --allow-no-migration --no-interaction -vv

db-clear-meta: ## Clear doctrine metadata cache
	$(SYMFONY) doctrine:cache:clear-metadata

migrate: ## Runs doctrine migrations without requiring user confirmation
	$(SYMFONY) d:m:m --no-interaction

migration: ## Generates a doctrine migration by comparing schema and entities
	rm -rf var/cache/* ; $(SYMFONY) doctrine:migrations:diff

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands
	$(SYMFONY)

cc: ## Clear the cache. DID YOU CLEAR YOUR CACHE????
	$(SYMFONY) cache:clear

warmup: ## Warmump the cache
	$(SYMFONY) cache:warmup

fix-perms: ## Fix permissions of all var files
	chmod -R 777 var/*

assets: purge ## Install the assets with symlinks in the public folder
	$(SYMFONY) assets:install public/ --symlink --relative

purge: ## Purge cache and logs
	rm -rf var/cache/* var/logs/*

custom-commands: ## Display all custom commands in the project namespace
	$(SYMFONY) list $(PROJECT)

## —— NPM 🎵 ———————————————————————————————————————————————————————————————
npm-ci: ## Install assets
	$(DOCKER_COMP) exec $(PHP_CONTAINER) npm ci

npm-dev: ## Compile assets
	$(DOCKER_COMP) exec $(PHP_CONTAINER) npm run dev

## —— Rabbitmq 📈 ———————————————————————————————————————————————————————————————
mq-consume: ## Consume Rabbitmq messages
	$(DOCKER_COMP) exec $(PHP_CONTAINER) php bin/console messenger:consume

mq-consume-verbose: ## Consume Rabbitmq messages verbose
	$(DOCKER_COMP) exec $(PHP_CONTAINER) php bin/console messenger:consume -vvv
## —— Tests 🧪 —————————————————————————————————————————————————————————————————
test: ## Launch all tests
	./vendor/bin/phpunit --stop-on-failure

test-unit: phpunit.xml ## Launch unit tests
	./vendor/bin/phpunit --testsuite=Unit --stop-on-failure

test-functional: phpunit.xml ## Launch functional tests
	./vendor/bin/phpunit --testsuite=Functional --stop-on-failure

## —— Coding standards 👌 ——————————————————————————————————————————————————————
check: cs-fix stan twig ## Launch check style and static analysis

cs-fix: ## Run php-cs-fixer and fix the code.
	$(COMPOSER) csfixer

stan: ## Run PHPStan only
	$(COMPOSER) stan

twig: ## Run Twig linter
	$(COMPOSER) twig
