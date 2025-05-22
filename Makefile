.PHONY: help up-auth up-payment up-board up-kafka up-all down logs

DOCKER_DIR = docker
ENV_FILE = --env-file ../.env

help: ## Показать справку
	@echo "Доступные команды:"
	@echo "  up-auth      - Запустить auth сервис"
	@echo "  up-payment   - Запустить payment сервис"
	@echo "  up-board     - Запустить board сервис"
	@echo "  up-calendar  - Запустить calendar сервис"
	@echo "  up-kafka     - Запустить Kafka кластер"
	@echo "  up-backend   - Запустить только backend сервисы"
	@echo "  up-all       - Запустить все сервисы"
	@echo "  down         - Остановить все сервисы"
	@echo "  logs         - Показать логи"
	@echo "  ps           - Показать статус контейнеров"

up-auth: ## Запустить auth сервис
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up auth_service auth_postgres -d

up-payment: ## Запустить payment сервис
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up payment_service payment_postgres -d

up-board: ## Запустить board сервис
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up board_service board_mongo board_redis board_mongo_express -d

up-kafka: ## Запустить Kafka кластер
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up zookeeper kafka_broker_1 kafka_broker_2 kafka_broker_3 schema_registry kafka_ui -d
	@echo "Создание топиков..."
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) run --rm kafka_topics_setup

up-calendar: ## Запустить calendar сервис
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up calendar_service calendar_mongo calendar_redis calendar_mongo_express -d

up-backend: ## Запустить только backend сервисы
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up auth_service auth_postgres payment_service payment_postgres board_service board_mongo board_redis calendar_service calendar_mongo calendar_redis -d

up-all: ## Запустить все сервисы
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) up -d

down: ## Остановить все сервисы
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) down

logs: ## Показать логи
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f

logs-auth: ## Логи auth сервиса
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f auth_service

logs-payment: ## Логи payment сервиса
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f payment_service

logs-board: ## Логи board сервиса
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f board_service

logs-calendar: ## Логи calendar сервиса
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f calendar_service

logs-kafka: ## Логи Kafka
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) logs -f kafka_broker_1 kafka_broker_2 kafka_broker_3

ps: ## Показать статус контейнеров
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) ps

kafka-topics: ## Создать Kafka топики
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) run --rm kafka_topics_setup

restart: ## Перезапустить все сервисы
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) restart

clean: ## Удалить все контейнеры и volumes
	cd $(DOCKER_DIR) && docker compose $(ENV_FILE) down -v
	docker system prune -f

clean-db: ## Удалить только volumes с базами данных
	@echo "⚠️  Это удалит ВСЕ данные из баз!"
	@read -p "Продолжить? (y/N): " confirm && [ "$confirm" = "y" ]
	docker volume rm docker_auth_postgres_data docker_payment_postgres_data docker_board_mongo_data docker_auth_redis_data docker_payment_redis_data docker_board_redis_data 2>/dev/null || true