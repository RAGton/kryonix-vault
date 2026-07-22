# Kryonixos pin do kryxd Control Center UI

Data: 2026-07-22
Agente: Aura
Repos afetados:

- repos/kryonixos
- repos/kryxd
- repos/kryonix-vault
- kryonix-dev

## Objetivo

Remover a necessidade do override local `--override-input kryonix/kryxd path:/home/rocha/kryonix-dev/repos/kryxd` no host `inspiron`, fixando no `flake.lock` downstream o commit da `main` do `kryxd` que contém a absorção do Control Center no roteamento oficial do `kryxd/ui`.

## Contexto consultado

- `repos/kryonixos/AGENTS.md`.
- `repos/kryonixos/flake.nix`.
- `repos/kryonixos/flake.lock`.
- `repos/kryxd/src/api/auth.rs`.
- `repos/kryxd/ui/src/views/Login.tsx`.
- Estado Git dos repositórios afetados.

## Mudanças realizadas

Em `repos/kryonixos`:

- Atualizado apenas `flake.lock`.
- Node `kryxd` atualizado de:
  - `6ea5cb8d103170947a75e736dd4b11a3faae9c64`
- Para:
  - `d707851a72c9cced3db7610d28f78b4d26e408f3`

O comando `nix flake update kryxd kryonix` não alterou o lock porque `kryxd` não é input direto do flake downstream; ele é input aninhado via `kryonix/kryxd`. A atualização efetiva foi feita com:

```bash
nix flake lock --update-input kryonix/kryxd --update-input kryonix
```

## Commits e branches

Em `repos/kryonixos`:

- Branch: `main`
- Commit: `ac2e6be chore(flake): pin updated kryxd main with PAM control center UI`
- Push: `ae7ad54..ac2e6be main -> main`

## Validações executadas

### Lockfile

Confirmado via parser JSON do `flake.lock`:

```txt
kryxd d707851a72c9cced3db7610d28f78b4d26e408f3 file:///home/rocha/kryonix-dev/repos/kryxd
kryonix d5681dcea6dd694bed04396fc6c4da04328cd48d RAGton/kryonix
```

### Downstream eval

```bash
nix flake check --keep-going --impure
```

Resultado:

```txt
all checks passed!
```

Warnings observados, não bloqueantes:

- `system` renomeado para `stdenv.hostPlatform.system`.
- `boot.zfs.forceImportRoot` usando default `true`.

### Rebuild sem override local

```bash
sudo nixos-rebuild test --flake .#inspiron --impure --show-trace -L
```

Resultado:

```txt
Done. The new configuration is /nix/store/pg5dcn7c1rrcpzqldhzqicab0pwlqgy4-nixos-system-inspiron-26.05.20260625.4062d36
```

O build do `kryxd-ui` e do `kryxd` ocorreu a partir do lock sem `--override-input`.

Warnings observados no build:

- Vite manteve `/img/noise.png` para resolução em runtime.
- Chunk JS maior que 500 kB.
- Rust warnings preexistentes em `kryxd`:
  - `private_interfaces` para `load_install_state`.
  - `dead_code` para `expected_password`.

### Runtime do serviço

Após `nixos-rebuild test`:

```txt
kryxd.service: active/running
ExecStart: /nix/store/5vld48rbai38phd3qfylxdgfnpszgs1k-kryxd-0.1.0/bin/kryxd
listener: 0.0.0.0:8080
```

### API segura sem segredo

```bash
curl -i http://127.0.0.1:8080/api/v1/system/identity
```

Resultado:

```txt
HTTP/1.1 200 OK
{"uuid":"b8d7c377c2194646bf0fde3044c6bd32","role":"Desktop","edition":"Kryonix Desktop"}
```

```bash
curl -i http://127.0.0.1:8080/api/v1/auth/session
```

Resultado:

```txt
HTTP/1.1 401 Unauthorized
{"error":"SESSION_REQUIRED","details":"Sessão inválida ou expirada"}
```

```bash
curl -i -X POST http://127.0.0.1:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"rocha","password":"senha_falsa_teste"}'
```

Resultado:

```txt
HTTP/1.1 401 Unauthorized
{"error":"INVALID_CREDENTIALS","details":"Usuário ou senha inválidos"}
```

### Browser

Acessado:

```txt
http://127.0.0.1:8080/login
```

Evidência:

- página carregou com título `Kryonix Installer`;
- exibiu `DESKTOP LOCAL`;
- exibiu `host local · Kryonix Desktop`;
- exibiu aviso: `Perfil fixo detectado em /api/v1/system/identity. A seleção manual de Desktop/Think Server/Node fica bloqueada neste host.`;
- console do navegador: 0 mensagens, 0 erros.

Não foi digitada senha real do usuário. Login real deve ser validado manualmente por Gabriel no navegador.

## Resposta à questão arquitetural: duração da sessão PAM

Em `repos/kryxd/src/api/auth.rs`:

- `SESSION_TTL_SECONDS` é fixo em `15 * 60`, ou seja, 15 minutos.
- O token recebe `iat` e `exp` no login.
- O endpoint `/api/v1/auth/session` apenas valida o token existente e retorna `expires_at`.
- Não há renovação automática/rolling session a cada requisição válida no código atual.

## Pendências

- Gabriel validar login real manualmente no navegador usando a senha Linux local. A Aura não manipula senha.
- Resolver em tarefa futura o aviso visual `/img/noise.png` se aparecer quebrado em runtime.
- Resolver em tarefa futura warnings Rust preexistentes e/ou chunk split do Vite, se virar meta de qualidade.
- Workspace ainda tem sujeiras fora do escopo, preservadas:
  - `repos/kryonixos/hosts/inspiron/default.nix`;
  - arquivos `.obsidian` no Vault;
  - artefatos locais do Control Center importado.

## Próximo passo recomendado

Gabriel deve abrir `http://127.0.0.1:8080/login`, fazer hard refresh (`Ctrl+Shift+R`) e validar login real. Se entrar e redirecionar para `/desktop/summary`, o ciclo fica pronto para planejar o próximo switch permanente com muito menos gambiarra — finalmente 😄
