# Requires .vault-pass at repo root for vault recipes

default:
    @just --list

# Install deps and run ansible-lint + yamllint
lint:
    pip install -q -r requirements.txt
    ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass ansible-lint ansible/playbooks/site.yml
    yamllint .

lint-yaml:
    yamllint .

lint-ansible:
    ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass ansible-lint ansible/playbooks/site.yml

vault-view:
    ansible-vault view --vault-password-file .vault-pass ansible/vault/secrets.yml

vault-edit:
    ansible-vault edit --vault-password-file .vault-pass ansible/vault/secrets.yml

vault-encrypt:
    ansible-vault encrypt --vault-password-file .vault-pass ansible/vault/secrets.yml

vault-rekey:
    ansible-vault rekey --vault-password-file .vault-pass ansible/vault/secrets.yml

# Symlink hooks/pre-commit into .git/hooks/
install-hooks:
    ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
    chmod +x hooks/pre-commit
    @echo "Git hooks installed."
