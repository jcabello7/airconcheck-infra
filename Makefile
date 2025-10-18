.PHONY: help secrets-init secrets-status secrets-encrypt secrets-decrypt secrets-edit secrets-view secrets-rekey

SECRETS=group_vars/secrets.yml
SECRETS_EXAMPLE=group_vars/secrets.yml.example

VAULT?=ansible-vault

help:
	@echo "Secrets helpers:"
	@echo "  make secrets-init      # copy example to secrets.yml if missing"
	@echo "  make secrets-status    # show whether secrets.yml exists and if it's vaulted"
	@echo "  make secrets-encrypt   # encrypt secrets.yml with ansible-vault"
	@echo "  make secrets-decrypt   # decrypt secrets.yml (use with care)"
	@echo "  make secrets-edit      # edit with ansible-vault"
	@echo "  make secrets-view      # view with ansible-vault"
	@echo "  make secrets-rekey     # change vault password/key"

secrets-init:
	@if [ ! -f $(SECRETS) ]; then \
		cp $(SECRETS_EXAMPLE) $(SECRETS); \
		echo "Created $(SECRETS) from example"; \
	else \
		echo "$(SECRETS) already exists"; \
	fi

secrets-status:
	@if [ -f $(SECRETS) ]; then \
		if head -n1 $(SECRETS) | grep -q '^\$ANSIBLE_VAULT;'; then \
			echo "$(SECRETS): ENCRYPTED"; \
		else \
			echo "$(SECRETS): PLAIN"; \
		fi; \
	else \
		echo "$(SECRETS): MISSING"; \
	fi

secrets-encrypt:
	@test -f $(SECRETS) || (echo "$(SECRETS) missing. Run 'make secrets-init' first." && exit 1)
	$(VAULT) encrypt $(SECRETS)

secrets-decrypt:
	@test -f $(SECRETS) || (echo "$(SECRETS) missing." && exit 1)
	$(VAULT) decrypt $(SECRETS)

secrets-edit:
	@test -f $(SECRETS) || (echo "$(SECRETS) missing." && exit 1)
	$(VAULT) edit $(SECRETS)

secrets-view:
	@test -f $(SECRETS) || (echo "$(SECRETS) missing." && exit 1)
	$(VAULT) view $(SECRETS)

secrets-rekey:
	@test -f $(SECRETS) || (echo "$(SECRETS) missing." && exit 1)
	$(VAULT) rekey $(SECRETS)
