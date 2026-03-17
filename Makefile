.PHONY: help lint test check install clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint: ## Run shellcheck on all scripts
	shellcheck -S warning scripts/*.sh

test: ## Run bats tests
	bats tests/

check: lint test ## Run lint + tests

install: ## Symlink scripts to ~/.local/bin
	@mkdir -p ~/.local/bin
	@for f in scripts/altfins_*.sh; do \
		name=$$(basename "$$f"); \
		ln -sf "$$(pwd)/$$f" ~/.local/bin/"$$name"; \
		echo "Linked $$name"; \
	done
	@echo "Done. Ensure ~/.local/bin is in your PATH."

clean: ## Remove cache files
	rm -rf ~/.config/altfins-skill/cache/
	@echo "Cache cleared."

package: ## Package skill as ZIP for distribution
	@mkdir -p dist
	zip -r dist/altfins-skill.zip \
		SKILL.md scripts/ references/api-reference.md LICENSE \
		-x "scripts/.*.swp" -x "*.bak"
	@echo "Package created: dist/altfins-skill.zip"
