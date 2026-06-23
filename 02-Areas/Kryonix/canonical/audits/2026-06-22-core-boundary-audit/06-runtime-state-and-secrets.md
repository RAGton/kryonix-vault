# Runtime, estado e secrets

## O que nunca deve entrar no Git

- `brain.env` — já no `.gitignore` ✅
- `neo4j.env` — já no `.gitignore` ✅
- `.env` — já no `.gitignore` ✅
- Tokens, chaves SSH/GPG, `id_*`
- `*.pem`, `*.key`, `*.secret`, `*.token`

## Estado operacional

Caminhos de runtime encontrados no código:
- `/var/lib/kryonix/` — estado principal
- `/var/lib/kryonix/brain/` — estado do Brain (storage, neo4j, backups)
- `/var/lib/kryonix/vault/` — vault em runtime
- `/var/lib/kryonix/backups/` — backups

## Logs

- Logs devem ficar em `/var/log/` ou via `journalctl`
- Não há evidência de logs sendo commitados ✅

## Cache

- `packages/kryonix-brain-lightrag/.venv/` — venv local, NÃO deve ser commitado (já no `.gitignore`)
- `packages/kryonix-brain-lightrag/target/` — build Rust, NÃO deve ser commitado (já no `.gitignore`)
- `packages/kryonix-brain-lightrag/__pycache__/` — cache Python

## Secrets

**Encontrados no código (apenas referências seguras):**
- `scripts/kryonix-secret-scan.py` — scanner de secrets (ferramenta de segurança)
- `features/ai.nix` — lê `/etc/kryonix/brain.env` via shell (apenas referência, não expõe valor)
- `modules/nixos/services/brain.nix` — `environmentFile = "/etc/kryonix/brain.env"` (apenas caminho)

**Nenhum valor de secret foi encontrado no código. ✅**

## Caminhos permitidos

- `/etc/kryonix/*.env` — secrets em runtime (gitignored)
- `/var/lib/kryonix/` — estado operacional
- `~/.local/state/kryonix/` — estado do usuário

## Caminhos proibidos

- `/nix/store` — nunca conter secrets
- `.nix` files — nunca conter valores de secrets
- Logs de CI — nunca expor secrets
- `flake.lock` — nunca conter tokens
