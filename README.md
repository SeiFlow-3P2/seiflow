# SeiFlow

Микросервисная платформа для управления проектами.

## 🚀 Быстрый старт

### Требования
- Docker & Docker Compose
- Git
- Make

### Установка

```bash
git clone https://github.com/SeiFlow-3P2/seiflow.git
cd seiflow
```
### Запуск
```bash
./scripts/setup.sh
```

Скрипт автоматически:
- ✅ Проверит зависимости (Docker, Docker Compose, Git)
- ✅ Создаст .env файл из .env.example
- ✅ Создаст необходимые директории для данных
- ✅ Инициализирует git submodules
- ✅ Проверит доступность портов

## 📋 Доступные команды

### Что работает сейчас:

```bash
make kafka          # Запустить Kafka (с автосозданием топиков)
make monitoring     # Запустить мониторинг (Prometheus, Grafana, Jaeger)
```

### Основные команды:

```bash
make help           # Показать все команды
make ps             # Статус контейнеров
make logs           # Логи всех сервисов
make down           # Остановить все сервисы
make clean          # Полная очистка (включая volumes)
```

## 🌐 URL-адреса

После запуска доступны:

| Сервис | URL | Логин/Пароль |
|--------|-----|--------------|
| Kafka UI | http://localhost:8086 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| Jaeger | http://localhost:16686 | - |


## 📊 Kafka топики

При запуске автоматически создаются:
- `board.event` - события от доски к календарю
- `calendar.notify` - уведомления от календаря

## ⚠️ Известные проблемы

- **API Gateway** - требуется Dockerfile
- **Board Service** - требуется Dockerfile  
- **Auth Service** - не запускается
- **Payment Service** - не запускается
- **Calendar Service** - не запускается

## 🔧 Структура проекта

```
seiflow/
├── docker/
│   ├── infrastructure/   # Kafka, Monitoring
│   └── services/        # Микросервисы
├── services/            # Git submodules
├── scripts/            # Скрипты автоматизации
└── Makefile           # Команды управления
```

## 🛠️ Разработка

Для разработки отдельных сервисов используйте соответствующие submodules в директории `services/`.