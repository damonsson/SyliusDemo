.PHONY: install

install:
	@make composer-install
	@make rdb
	@make frontend

composer-install:
	@docker-compose exec php composer install

rdb:
	@docker-compose exec php sh -c 'if bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; then bin/console doctrine:database:drop --force; fi'
	@docker-compose exec php bin/console doctrine:database:create
	@docker-compose exec php bin/console doctrine:schema:create
	@docker-compose exec php bin/console sylius:fixtures:load -n

frontend:
	@docker-compose exec php yarn install
	@docker-compose exec php yarn encore prod

php-shell:
	@docker-compose exec php sh
