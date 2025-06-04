# 🚀 SeiFlow

> Микросервисная платформа для управления проектами с современной архитектурой

[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=github-actions)](https://github.com/SeiFlow-3P2/seiflow/actions)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://www.docker.com/)
[![Kafka](https://img.shields.io/badge/Apache-Kafka-black?logo=apache-kafka)](https://kafka.apache.org/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-orange?logo=prometheus)](https://prometheus.io/)

---

## 📋 Оглавление

- [🎯 Быстрый старт](#-быстрый-старт)
- [📦 Архитектура](#-архитектура)
- [🛠️ Доступные команды](#️-доступные-команды)
- [🌐 Сервисы и адреса](#-сервисы-и-адреса)
- [⚡ Что работает](#-что-работает)
- [🔧 В разработке](#-в-разработке)
- [📊 Мониторинг](#-мониторинг)
- [🚨 Известные проблемы](#-известные-проблемы)

---

## 🎯 Быстрый старт

### Требования
- 🐳 **Docker** & **Docker Compose**
- 📁 **Git**
- 🔨 **Make**

### Установка

```bash
# Клонируем репозиторий
git clone https://github.com/SeiFlow-3P2/seiflow.git
cd seiflow

# Автоматическая настройка
./scripts/setup.sh
```

Скрипт автоматически:
- ✅ Проверит зависимости (Docker, Docker Compose, Git)
- ✅ Создаст `.env` файл из `.env.example`
- ✅ Создаст необходимые директории для данных
- ✅ Инициализирует git submodules
- ✅ Проверит доступность портов

---

## 📦 Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   🌐 Frontend   │    │  🚪 API Gateway │    │  🔐 Auth Service│
│   (React/Vue)   │◄──►│   (Go/Gin)      │◄──►│    (Go/gRPC)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
          ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
          │📋 Board     │ │📅 Calendar  │ │💳 Payment   │
          │  Service    │ │   Service   │ │   Service   │
          │(Go/MongoDB) │ │(Go/MongoDB) │ │(Go/Postgres)│
          └─────────────┘ └─────────────┘ └─────────────┘
                    │           │           │
                    └───────────┼───────────┘
                                ▼
                    ┌─────────────────────────┐
                    │      🔔 Notification    │
                    │        Service          │
                    │      (Go/Telegram)      │
                    └─────────────────────────┘
```

---

## 🛠️ Доступные команды

### 🚀 Основные команды

```bash
make help           # 📖 Показать все команды
make up             # 🚀 Запустить все сервисы
make down           # 🛑 Остановить все сервисы
make ps             # 📊 Статус контейнеров
make logs           # 📝 Логи всех сервисов
make clean          # 🧹 Полная очистка (включая volumes)
```

### 🔧 Отдельные компоненты

```bash
# Инфраструктура
make kafka          # 🔥 Запустить Kafka кластер
make monitoring     # 📊 Запустить мониторинг (Prometheus + Grafana + Jaeger)
make nginx          # 🌐 Запустить Nginx

# Сервисы (требуют Dockerfile)
make payment        # 💳 Запустить Payment сервис

# Готовы
make auth           # 🔐 Auth сервис
make board          # 📋 Board сервис
make calendar       # 📅 Calendar сервис
make gateway        # 🚪 API Gateway
make notification   # 🔔 Запустить Notification сервис
```

### 🏥 Проверка здоровья

```bash
make health         # 🩺 Проверить здоровье всех сервисов
```

---

## 🌐 Сервисы и адреса

После запуска `make up` доступны следующие сервисы:

### 🎛️ Инфраструктура и мониторинг

| 🛠️ Сервис | 🌐 URL | 👤 Логин/Пароль | 📝 Описание |
|-----------|--------|------------------|-------------|
| **Kafka UI** | [localhost:8086](http://localhost:8086) | - | Управление Kafka топиками |
| **Grafana** | [localhost:3000](http://localhost:3000) | `admin/admin` | Дашборды и метрики |
| **Prometheus** | [localhost:9090](http://localhost:9090) | - | Сбор метрик |
| **Jaeger** | [localhost:16686](http://localhost:16686) | - | Трейсинг запросов |

### 🔗 Основные сервисы

| 🛠️ Сервис | 🌐 URL | 📱 Порт | 📝 Статус |
|-----------|--------|---------|-----------|
| **Frontend** | [localhost:80](http://localhost:80) | 80/443 | 🔧 В разработке |
| **API Gateway** | [localhost:8080](http://localhost:8080) | 8080 | 🔧 Требует Dockerfile |
| **Auth Service** | `localhost:8093` | 8093 | 🔧 Требует Dockerfile |
| **Board Service** | `localhost:8090` | 8090 | 🔧 Требует Dockerfile |
| **Calendar Service** | `localhost:8092` | 8092 | 🔧 Требует Dockerfile |
| **Payment Service** | `localhost:8091` | 8091 | ✅ Готов к запуску |
| **Notification Service** | - | - | 🔧 Требует Dockerfile |

---

## ⚡ Что работает

### ✅ Полностью функциональные компоненты

- 🔥 **Kafka кластер** (3 брокера + Zookeeper)
  - Автоматическое создание топиков
  - Kafka UI для управления
- 📊 **Мониторинг стек**
  - Prometheus для метрик
  - Grafana для визуализации
  - Jaeger для трейсинга
- 🌐 **Nginx** как reverse proxy
- 🔐 **SSL сертификаты** (самоподписанные)

### 📊 Kafka топики

При запуске автоматически создаются:
- `board.event` - события от доски к календарю
- `calendar.notify` - уведомления от календаря

---

### 🔧 Незавершенные конфигурации

- **OAuth провайдеры** (GitHub, Google) - требуют настройки
- **Grafana дашборды** - требуют создания
- **Frontend контент** - требует разработки

---

## 📊 Мониторинг

### 🎯 Метрики Prometheus

Автоматически собираются метрики с:
- 🔥 Kafka брокеров
- 🗄️ PostgreSQL и MongoDB
- 🚀 Redis кластеров
- 🛠️ Микросервисов (когда готовы)

### 📈 Grafana дашборды

После запуска доступны:
- Системные метрики
- Kafka метрики
- Метрики баз данных

---

## 🤝 Участие в разработке

### 📁 Структура проекта

```
seiflow/
├── 🐳 docker/
│   ├── infrastructure/    # Kafka, Monitoring, Nginx
│   ├── services/         # Конфигурации микросервисов
│   └── scripts/          # Утилиты (генерация SSL, топики)
├── 🛠️ services/          # Git submodules с исходным кодом
├── 🔧 scripts/           # Скрипты автоматизации
├── 📝 .github/workflows/ # CI/CD пайплайны
└── 📋 Makefile          # Команды управления
```

### 🔄 Git Submodules

Сервисы организованы как submodules:
- `services/auth_service`
- `services/board_service`
- `services/calendar_service`
- `services/payment_service`
- `services/api_gateway`
- `services/notification_service`
- `services/seiflow_frontend`

---

## 📞 Поддержка

Если у вас возникли проблемы:

1. 📖 Проверьте `make help`
2. 🩺 Запустите `make health`
3. 📝 Изучите логи `make logs`
4. 🐛 Создайте issue в GitHub

---

<div align="center">

**🎯 SeiFlow** - Современная платформа для управления проектами

[![Stars](https://img.shields.io/github/stars/SeiFlow-3P2/seiflow?style=social)](https://github.com/SeiFlow-3P2/seiflow)
[![Fork](https://img.shields.io/github/forks/SeiFlow-3P2/seiflow?style=social)](https://github.com/SeiFlow-3P2/seiflow/fork)

</div>