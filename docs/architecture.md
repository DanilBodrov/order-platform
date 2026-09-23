# Архитектура платформы

## 1. Обзор

Event-Driven Order Processing Platform. Микросервисы общаются через:

- **REST** — внешние вызовы клиентов через `api-gateway`.
- **gRPC** — внутренние синхронные вызовы с низкой задержкой.
- **Kafka** — асинхронные события между сервисами.

UI/SPA отсутствует, все функции доступны через REST/gRPC + Swagger UI.

## 2. Сервисы

### api-gateway
- Единая точка входа.
- Rate-limiting.
- Проверка JWT.
- Маршрутизация REST и gRPC.
- Зависимости: auth-service.

### auth-service
- Регистрация по email/паролю.
- Подтверждение email.
- OAuth 2.1 (Google, GitHub).
- JWT access + refresh tokens.
- БД: PostgreSQL.
- События: producer `user.created`.

### user-service
- CRUD пользователей.
- RBAC: ROLE_USER, ROLE_MANAGER, ROLE_ADMIN.
- БД: PostgreSQL.
- События: consumer `user.created`.

### product-service
- CRUD каталога (админы).
- Публикация/скрытие товаров.
- Поиск и фильтры: price range, category, text.
- БД: MongoDB.
- gRPC для внутренних вызовов.

### inventory-service
- Запасы и резервы.
- Kafka Streams.
- БД: PostgreSQL.
- gRPC для order-service.
- События: consumer `order.created`, producer `inventory.reserved`.

### order-service
- Создание и жизненный цикл заказа.
- Статусы: NEW → RESERVED → PAID → SHIPPED → COMPLETED / CANCELLED.
- Саговая компенсация при недостатке товара.
- БД: PostgreSQL.
- События: producer `order.created`, `order.status-changed`.

### notification-service
- Email/SMS/push.
- Rate-limiting по пользователю (Redis leaky bucket).
- БД: MongoDB.
- События: consumer `order.created`, `order.status-changed`.

## 3. Kafka-топики

| Topic                | Key     | Схема  | Producer          | Consumers                               |
|----------------------|---------|--------|-------------------|-----------------------------------------|
| user.created         | userId  | Avro   | auth-service      | user-service                            |
| order.created        | orderId | Avro   | order-service     | inventory-service, notification-service |
| inventory.reserved   | orderId | Avro   | inventory-service | order-service                           |
| order.status-changed | orderId | Avro   | order-service     | notification-service                    |

Схемы хранятся в Confluent Schema Registry.

## 4. Хранилища

- **PostgreSQL 15** — OLTP: пользователи, заказы, запасы.
- **MongoDB 7** — каталог, шаблоны уведомлений, логи.
- **Redis 7** — кэш горячих данных, distributed locks (Redlock), rate-limiter.

## 5. Безопасность

- JWT access + refresh.
- OAuth 2.1: Google, GitHub.
- RBAC: ROLE_USER / ROLE_MANAGER / ROLE_ADMIN.
- TLS 1.3.
- Секреты: Kubernetes Secrets / sealed-secrets.
- OWASP Top-10.
- Сканирование: OWASP Dependency-Check + Trivy, 0 критичных.

## 6. Наблюдаемость

- JSON-логи → Loki.
- Трассировка → OpenTelemetry + Jaeger.
- Метрики → Prometheus + Grafana.
- Alert-rules для критичных метрик.

## 7. Открытые вопросы

- **PAID без payment-service.** 
В ТЗ статус PAID есть, но payment-service не выделен. 
Решение: на текущем этапе оплата эмулируется внутри order-service (mock-провайдер). 
Если понадобится реальная интеграция — выделим payment-service отдельно (см. ADR).
