## This is a self-documented Makefile.
## For usage information, run `make help`:

.PHONY: all fmt server server-deps server-deps-clean server-fmt iex app help

all: database server

fmt: server-fmt

database: ## Run the database server.
	@echo "Running database server (Postgres)"
	@docker run --rm --name racquet_db -e POSTGRES_USER=racquet -e POSTGRES_PASSWORD=racquet -e POSTGRES_DB=racquet -p 5432:5432 -d postgres:15.2-alpine

database-mig: ## Run the database migrations.
	@echo "Running database migrations (mix ecto.migrate)"
	@(cd server && mix ecto.migrate)

server: server-deps ## Run the Elixir server.
	@echo "Running Elixir server (mix phx.server)"
	@(cd server && mix phx.server)

server-deps: server-deps-clean ## Install the Elixir server dependencies.
	@echo "Installing Elixir dependencies (mix deps.get)"
	@(cd server && mix deps.get)

server-deps-clean: ## Clean up the Elixir server dependencies.
	@echo "Cleaning up Elixir dependencies (mix deps.clean --unlock --unused)"
	@(cd server && mix deps.clean --unlock --unused)

server-fmt: ## Format the Elixir source code.
	@echo "Formatting Elixir source code (mix format)"
	@(cd server && mix format)

server-reset-db: ## Clean up the Elixir server database.
	@echo "Cleaning up the Elixir server database (mix ecto.drop && mix ecto.create)"
	@(cd server && mix ecto.drop && mix ecto.create)

iex: server-deps ## Start interactive Elixir shell for project.
	@echo "Starting an interactive shell (iex -S mix phx.server)"
	@(cd server && iex -S mix phx.server)

app: ## Run the Flutter application.
	@echo "Running Flutter application (flutter run)"
	@(cd app && flutter run)

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
