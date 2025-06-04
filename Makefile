.PHONY: help up down ps logs clean

# Цвета для красивого вывода
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Переменные
COMPOSE_CMD = docker compose --env-file .env
NETWORK_NAME = seiflow_backend

help: ## Показать эту справку
	@echo "$(GREEN)Доступные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

# === УПРАВЛЕНИЕ СЕТЬЮ ===
network: ## Создать общую сеть
	@docker network create $(NETWORK_NAME) 2>/dev/null || echo "$(YELLOW)Сеть $(NETWORK_NAME) уже существует$(NC)"

# === ЗАПУСК СЕРВИСОВ ===
auth: network ## Запустить Auth сервис
	@echo "$(GREEN)🚀 Запускаю Auth сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml up -d
	@echo "$(GREEN)✅ Auth сервис запущен$(NC)"

payment: network ## Запустить Payment сервис
	@echo "$(GREEN)🚀 Запускаю Payment сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/payment-service.yml up -d
	@echo "$(GREEN)✅ Payment сервис запущен$(NC)"

board: network ## Запустить Board сервис
	@echo "$(GREEN)🚀 Запускаю Board сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/board-service.yml up -d
	@echo "$(GREEN)✅ Board сервис запущен$(NC)"

calendar: network ## Запустить Calendar сервис
	@echo "$(GREEN)🚀 Запускаю Calendar сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/calendar-service.yml up -d
	@echo "$(GREEN)✅ Calendar сервис запущен$(NC)"

notification: network ## Запустить Notification сервис
	@echo "$(GREEN)🚀 Запускаю Notification сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/notification-service.yml up -d
	@echo "$(GREEN)✅ Notification сервис запущен$(NC)"

gateway: network ## Запустить API Gateway
	@echo "$(GREEN)🚀 Запускаю API Gateway...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/api-gateway.yml up -d
	@echo "$(GREEN)✅ API Gateway запущен$(NC)"

kafka: network ## Запустить Kafka
	@echo "$(GREEN)🚀 Запускаю Kafka...$(NC)"
	@$(COMPOSE_CMD) -f docker/infrastructure/kafka.yml up -d
	@echo "$(GREEN)✅ Kafka запущена$(NC)"

monitoring: network ## Запустить мониторинг
	@echo "$(GREEN)🚀 Запускаю мониторинг...$(NC)"
	@$(COMPOSE_CMD) -f docker/infrastructure/monitoring.yml up -d
	@echo "$(GREEN)✅ Мониторинг запущен$(NC)"

nginx: network ## Запустить nginx
	@echo "$(GREEN)🚀 Запускаю nginx...$(NC)"
	@$(COMPOSE_CMD) -f docker/infrastructure/nginx-service.yml up -d
	@echo "$(GREEN)✅ nginx запущен$(NC)"

up: network ## Запустить все сервисы
	@echo "$(GREEN)🚀 Сетап приложения$(NC)"
	./scripts/setup.sh
	@echo "$(GREEN)🚀 Генерация SSL сертификатов...$(NC)"
	./docker/scripts/generate-certs.sh
	@echo "$(GREEN)🚀 Запускаю все сервисы...$(NC)"
	@$(COMPOSE_CMD) up -d
	@echo "$(GREEN)✅ Все сервисы запущены$(NC)"

down: ## Остановить все сервисы
	@echo "$(GREEN)🚀 Остановка всех сервисов...$(NC)"
	@$(COMPOSE_CMD) down
	@echo "$(GREEN)✅ Все сервисы остановлены$(NC)"

# === ПРОВЕРКА ЗДОРОВЬЯ ===
health: ## Проверить здоровье сервисов
	@echo "$(YELLOW)🏥 Проверка здоровья сервисов...$(NC)"
	@echo ""
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(auth|payment|board|calendar|gateway)" || echo "$(RED)Сервисы не запущены$(NC)"