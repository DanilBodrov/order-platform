.PHONY: help dev-up dev-down dev-logs dev-ps dev-clean build test verify

help:
	@echo "Available targets:"
	@echo "  dev-up      - start local infrastructure (docker compose)"
	@echo "  dev-down    - stop local infrastructure"
	@echo "  dev-logs    - follow logs"
	@echo "  dev-ps      - show container status"
	@echo "  dev-clean   - stop and remove volumes"
	@echo "  build       - maven build (skip tests)"
	@echo "  test        - maven test"
	@echo "  verify      - maven verify (build + checkstyle + tests)"

dev-up:
	docker compose up -d
	@echo "Infrastructure is starting. Use 'make dev-ps' to check status."

dev-down:
	docker compose down

dev-logs:
	docker compose logs -f

dev-ps:
	docker compose ps

dev-clean:
	docker compose down -v

build:
	mvn -B -ntp clean package -DskipTests

test:
	mvn -B -ntp test

verify:
	mvn -B -ntp clean verify
