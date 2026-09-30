# Order Platform

Проект: Event-Driven Order Processing Platform для малого e-commerce.

## Стек

- Java 17+, Spring Boot 3, Spring Security 6
- Apache Kafka (Redpanda в dev), Confluent Schema Registry, Avro
- PostgreSQL 15, MongoDB 7, Redis 7
- Docker, Kubernetes (k3d), Helm
- gRPC для внутренних синхронных вызовов
- Prometheus, Grafana, Loki, OpenTelemetry + Jaeger

## Архитектура

Платформа состоит из 7 микросервисов:

| Сервис               | Назначение                        | БД         | Протоколы           |
|----------------------|-----------------------------------|------------|---------------------|
| api-gateway          | Единая точка входа, rate-limiting | —          | REST, gRPC          |
| auth-service         | JWT / OAuth 2.1, refresh-tokens   | PostgreSQL | REST                |
| user-service         | CRUD пользователей, RBAC          | PostgreSQL | REST, Kafka         |
| product-service      | Каталог товаров                   | MongoDB    | REST, gRPC, Kafka   |
| inventory-service    | Запасы и резервы                  | PostgreSQL | gRPC, Kafka Streams |
| order-service        | Жизненный цикл заказа             | PostgreSQL | REST, gRPC, Kafka   |
| notification-service | Email/SMS/push                    | MongoDB    | Kafka               |

Подробнее — в [docs/architecture.md](docs/architecture.md).

## Структура репозитория

```
services/   — микросервисы
libs/       — общие библиотеки (DTO, Kafka, proto)
infra/      — docker, helm
scripts/    — dev-up / dev-down
docs/       — архитектура и ADR
```

## Локальный запуск

Требования: Docker Desktop (WSL 2 backend), 2 CPU, 8 GB RAM, Java 17+, Maven 3.9+.

```bash
make dev-up     # поднять весь стек
make dev-down   # остановить
```

PowerShell:

```powershell
./scripts/dev-up.ps1
./scripts/dev-down.ps1
```

## Сборка и тесты

```bash
mvn -B verify
```
