
all: down
	@docker-compose -f srcs/docker-compose.yml up -d --build

push:
	@echo -n "enter a commit message: "
	@git add . && read commit && git commit -m "$$commit" && git push

down:
	@docker-compose -f srcs/docker-compose.yml down

stop:
	@docker-compose -f srcs/docker-compose.yml stop

start:
	@docker-compose -f srcs/docker-compose.yml start

clean: down
	@docker system prune -af

fclean: clean
	@rm -rf /home/$(USER)/data/wordpress/*
	@rm -rf /home/$(USER)/data/mariadb/*
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

logs:
	@docker-compose -f srcs/docker-compose.yml logs -f

.PHONY: all up down stop start clean fclean re logs
