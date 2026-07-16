# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Doutrina do projeto (não negociável)

O RAGOS é uma plataforma on-premises para clientes diskless em NixOS. Antes de mudar qualquer coisa, internalize estes contratos — todos vivem em `INSTRUCT.md`, `INSTRUCOES.md` e `AGENTS.md`:

- **Servidor é o centro operacional; cliente é hardware descartável.** Não mova lógica operacional para o cliente "por comodidade".
- **Contrato atual de root do cliente** (estado **implementado**): `/nix/store` remoto via NFS (ro) + overlay tmpfs (rw). Persistência só em `/home` via NFSv4.
- **Roadmap** (não vender como atual): netboot/SquashFS. Documento, código e runbook ainda não fecham esse contrato.
- **Fronteira de CLI:** `ragos` opera o servidor e a infraestrutura; `ragc` opera a imagem publicada do cliente. WOL pertence ao `ragos`, nunca ao `ragc`.
- **Documentação é contrato.** Sempre separar `estado atual implementado` × `direção oficial` × `roadmap`. Misturar os três é o erro recorrente que esta governança existe para evitar.

Antes de editar, leia primeiro o documento canônico da área (ver "Leitura mínima por área" em `AGENTS.md`).

## Workspaces e checkouts

Três checkouts coexistem na máquina do mantenedor — não confunda:

| Path | Papel |
| --- | --- |
| `~/code/ragos` | **Checkout de desenvolvimento.** Único workspace de edição. |
| `/etc/ragos` | **Checkout operacional do host.** Usado para `ragos switch` / `ragc switch`. Nunca editar como workspace primário; nunca tratar como fonte de verdade do repo. |
| `~/Documents/...` | **Backup read-only.** Proibido como workspace. |

`/etc/ragos-inventory/clients.nix` é o inventário operacional (fora do repo). `/var/lib/ragos/runtime/*` é o runtime persistente real do host — os outputs oficiais do flake dependem dele.

## Arquitetura do flake (essencial)

`flake.nix` materializa **duas famílias paralelas** de `nixosConfigurations` que parecem redundantes mas têm semântica diferente:

- **Família `dev` — `ragos-client-dev-*`:** usa `flake/default-params.nix` (defaults genéricos). Avalia sempre, sem precisar de runtime instalado. Use para `nix eval`, `flake check` e CI.
- **Família oficial — `srv-rag`, `ragos-client`, `ragos-client-<profile>`:** lê `server/runtime/` e exige `runtimeSourceKind == "runtime"`. Avaliar fora de um host instalado **falha por design** com a mensagem "outputs oficiais exigem runtime persistente real em …". Isso é proteção, não bug.

Perfis canônicos do cliente (em `client/profiles/`): `desktop-generic` (produção física), `desktop-lab` (lab físico/libvirt, preserva `tty1` + `ttyS0`, sem Plymouth), `hyperv-debug` (lab/CI), `rescue-minimal`.

Canais publicados pelo `ragc`: `generic`, `lab`, `rescue`. A escolha de canal mapeia para profile (`lab → desktop-lab`, resto → `desktop-generic`).

## Fronteiras por diretório

| Diretório | Responsabilidade |
| --- | --- |
| `flake.nix`, `flake/` | Composição, `specialArgs`, validações, packages — **não** depósito de lógica ad hoc |
| `server/` | Host `srv-rag`: boot (PXE/iPXE/HTTP), rede, storage, NFS, runtime, serviços, `ragos-cli.nix` |
| `client/` | Imagem do cliente: profiles, modules, desktop, mounts, integração de endpoint |
| `installer/` | Live ISO + UI React + backend Rust/Axum + shell que prepara disco e roda `nixos-install`. Contrato em `docs/installer-contract-matrix.md` e `docs/install-plan-schema.md` |
| `ragc/` | Build, publish, rollback, GC, manifests da imagem do cliente. Não vira inventário, automação elétrica nem controle de servidor |
| `themes/` | Branding compartilhado (Plymouth, SDDM, Plasma, GTK, fontes, wallpapers) |
| `scripts/dev/`, `scripts/ops/`, `scripts/tests/`, `scripts/lab/` | Separados por intenção — ver "Scripts" abaixo |
| `docs/` | Doc canônica (com `Status` / `Scope` / `Last reviewed`). Histórico vai para `docs/archive/` |
| `.codex/agents/`, `.agents/skills/` | Estrutura canônica de agentes/skills do Codex local. **Não** reintroduzir `.codex/skills/` |

## Comandos essenciais

Sempre rode com `nix --extra-experimental-features 'nix-command flakes'` se o ambiente não tiver flakes habilitados globalmente.

**Validação mínima (reproduz CI):**

```bash
./scripts/tests/lint-repo-organization.sh           # ou: nix run .#repo-hygiene-lint
nix flake check
nix eval path:$PWD#nixosConfigurations.srv-rag.config.networking.hostName
nix eval path:$PWD#nixosConfigurations.ragos-client-desktop-generic.config.ragos.profile.name
```

**Suítes de teste por contrato** (rode a mais barata que cubra o que tocou):

```bash
./scripts/tests/test-clients-inventory-validation.sh   # inventário
./scripts/tests/test-client-inventory-routing.sh       # by-mac routing
./scripts/tests/test-runtime-guardrails.sh             # runtime persistente
./scripts/tests/test-ragc-phaseA.sh                    # fluxo ragc
./scripts/tests/test-ragc-channels.sh                  # canais ragc
./scripts/tests/test-installer-live-media-contract.sh  # ISO/live media
./scripts/tests/test-day0-contract.sh                  # Day-0: install + first publish
./scripts/tests/test-brandlab-contract.sh              # branding
./scripts/tests/test-codex-skills-structure.sh         # estrutura .codex/.agents
```

Rodar **um único teste**: invoque o `.sh` diretamente. Eles são auto-suficientes (criam tempdir, não tocam o host) — exceto os de `scripts/lab/`, que assumem ambiente local específico.

**Para construir a ISO** (precisa de `installer/default.nix` presente):

```bash
nix build .#ragos-iso
```

**CI** (`.github/workflows/ci.yml`): roda `nix run .#repo-hygiene-lint` + `nix flake check`. Se mudar contrato testado por um harness em `scripts/tests/`, certifique que ele continua passando.

## Scripts: regra de fronteira

A categoria é parte do contrato — não use a errada:

- `scripts/ops/` — automação **suportada** em produção. Seguro, idempotente, parametrizável.
- `scripts/tests/` — harnesses reproduzíveis. Sem topologia local. Devem rodar em CI ou em tempdir.
- `scripts/dev/` — automações de laboratório reproduzíveis (KVM/libvirt). Já nascem parametrizáveis.
- `scripts/lab/` — **explicitamente não canônico**. Pode ter caminhos pessoais, nomes fixos de VM, Hyper-V/QEMU/WSL. **Nunca trate script de lab como prova de design de produção.**

Todo script novo deve abrir com cabeçalho `Purpose` / `Category` / `Safety` (`lint-repo-organization.sh` valida isso).

## Mudou contrato? Atualize a doc no mesmo PR

`INSTRUCT.md` §5 lista as combinações obrigatórias. Resumo:

- **Boot:** `README.md`, `docs/boot-process.md`, `docs/architecture.md`, `docs/network.md`, `docs/runbook.md`
- **Storage / persistência:** `README.md`, `docs/storage.md`, `docs/server.md`, `docs/runbook.md`
- **CLI / contrato operacional:** `README.md`, `docs/runbook.md`, `docs/roadmap.md` (+ `INSTRUCT.md` se fronteira mudar)
- **Direção estratégica:** `README.md`, `INSTRUCOES.md`, `docs/roadmap.md`

Documento em `docs/` que não reflete mais o sistema → atualize **ou** mova para `docs/archive/`. Não deixe drift acumular.

## Entrega esperada (de `AGENTS.md`)

Toda resposta de implementação deve deixar claro: classificação da tarefa, contexto confirmado no código, arquivos lidos, arquivos criados/atualizados, validações executadas, riscos remanescentes, decisão final. Se algo não foi executado, declare sem rodeio — não chame screenshot ou overlay temporário de prova de entrega.
