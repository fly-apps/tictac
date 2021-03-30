.PHONY: help

APP_NAME ?= tictac

build: ## Build the Docker image
	docker build -t $(APP_NAME):latest .
