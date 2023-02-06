## This is a self-documented Makefile.
## For usage information, run `make help`:

.PHONY: all server server-deps app help

all: server

server: server-deps ## Run the Elixir server.
	@echo "Running Elixir server (mix phx.server)"
	@(cd server && mix phx.server)

server-deps: ## Install the Elixir server dependencies.
	@echo "Installing Elixir dependencies (mix deps.get)"
	@(cd server && mix deps.get)

app: ## Run the Flutter application.
	@echo "Running Flutter application (flutter run)"
	@(cd app && flutter run)

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
