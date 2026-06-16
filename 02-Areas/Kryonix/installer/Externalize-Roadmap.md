---
type: project-note
project: Kryonix
subproject: Installer Externalization → KryonixOS Release
status: in-progress
created: 2026-06-15
updated: 2026-06-15
tags:
  - kryonix
  - installer
  - release
  - kryonixos
  - roadmap
links:
  - "[[MOC - Installer]]"
  - "[[MOC - Kryonix]]"
  - "[[ROADMAP]]"
  - "[[ACTIVE_WORK]]"
  - "[[CURRENT_STATE]]"
  - "[[DEV PROD Flow]]"
  - "[[Target Flake v2]]"
---

# Externalizar Kryonix Installer + Fechar a ISO (KryonixOS RC1)

> Fonte de verdade para a sequência de PRs que tira o source do installer
> do sistema instalado, fecha a ISO real, e leva o projeto ao primeiro
> release-candidate da distro. **Nada de `kryonix switch` / `nixos-rebuild`
> / `disko` / `mkfs.*` sem instrução humana explícita.**

## Por quê

A auditoria 2026-06-14 confirmou: `packages/kryonix-installer/` é copiado
para `/mnt/etc/kryonixos/engine/packages/kryonix-installer/` durante o
install — a `COPY_DENYLIST` do `target_tree.rs` filtra `target/`,
`node_modules/`, `dist/`, segredos, mas **não filtra o pacote em si**. O
CLI no sistema instalado depende apenas do **binário** (não do source).
Externalizar via flake input limpa o target e mantém a ergonomia atual.

Repo standalone: <https://github.com/RAGton/kryonix-installer>

## P0 — Bloqueadores antes de chamar “pronta”

### 1. Finalizar externalização do installer

| Passo | Estado | Branch / PR |
|-------|--------|-------------|
| Bootstrap repo standalone (subtree split + flake + CI) | ✅ ABERTO MERGEABLE | [PR #1 RAGton/kryonix-installer](https://github.com/RAGton/kryonix-installer/pull/1) — branch `initial-flake-and-ci` |
| Mergear PR #1 | ⏳ | (humano) |
| Consumir installer via flake input no motor | ⏳ | `installer/externalize-input-p1` |
| Impedir source no target instalado | ⏳ | `installer/exclude-installer-from-target-p2` |
| Remover source interno | ⏳ | `installer/remove-internal-source-p3` |

Critério de pronto:

- [ ] ISO continua com installer funcionando.
- [ ] CLI continua encontrando o binário `kryonix-installer`.
- [ ] Sistema instalado **NÃO** carrega `packages/kryonix-installer/` source.
- [ ] Target flake (`/mnt/etc/kryonixos`) segue pure-eval e autocontido.

### 2. Build ISO completo (não só toplevel)

```bash
cd /home/rocha/kryonix/kryonix || exit 1
test "$(pwd -P)" = "/home/rocha/kryonix/kryonix" || exit 1

nix build .#nixosConfigurations.iso.config.system.build.isoImage \
  --out-link /tmp/kryonix-final-iso \
  -L --show-trace
```

Critério:
- [ ] ISO gera sem erro.
- [ ] Nome/label = `KryonixOS-Installer`.
- [ ] Sem dependência impura, sem `--impure`.

### 3. Smoke test real em VM libvirt

1. boot ISO em VM limpa
2. abrir UI kiosk
3. testar `/health`, `/network/status`, `/api/disks`
4. rodar `/dry-run`
5. instalar real no qcow2 da VM
6. rebootar pelo disco instalado
7. confirmar sistema sobe
8. confirmar `/etc/kryonixos` existe e target flake funciona

Critério:
- [ ] VM boota pela ISO.
- [ ] UI abre.
- [ ] Backend responde `/health`.
- [ ] Install termina `exitCode=0`.
- [ ] VM instalada boota pelo qcow2.
- [ ] Nenhum source do installer no target final.

### 4. Validar target instalado limpo

Após install em VM:

```bash
find /mnt/etc/kryonixos/engine -maxdepth 4 -type d -name "kryonix-installer" -print
find /mnt/etc/kryonixos/engine -path "*packages/kryonix-installer*" -print
```

Esperado: nenhuma ocorrência. Binário pode existir via `/nix/store` — OK.

## P1 — Necessário para release profissional

### 5. Triar CI #79 (workflows quebrados)

Workflows pendentes a triar: `Build & Test ISO`, `Nix Validation`,
`Rust Audit (Home)`, `Security Scan`, `Claude Code Action`. Para cada:

| Workflow | Bloqueia release? | Causa conhecida? | Issue linkada? |
|----------|-------------------|------------------|----------------|
| Build & Test ISO | ? | ? | #79 |
| Nix Validation | ? | ? | #79 |
| Rust Audit (Home) | ? | ? | #79 |
| Security Scan | ? | ? | #79 |
| Claude Code Action | ? | ? | #79 |

Release pública não sai com CI vermelho.

### 6. Backend hardening P2 (`installer/backend-hardening-p2`)

- payload gigante / null bytes / path traversal
- `deny_unknown_fields` em todas as structs
- erros JSON consistentes
- timeout de operações longas
- logs sem secrets
- `/install mode=dry-run` provadamente não destrutivo

Critério: `cargo test` + `clippy -D warnings` + `nix build .#kryonix-installer` + testes de payload inválido.

### 7. UI final do installer

Telas: Welcome, Network, RemoteAccess, HostSelection, MachineProfile,
SystemFeatures, UserFeatures, Disks, Users, Summary, Install progress,
Error, Success.

Faltam:
- mensagens melhores quando disco já está montado;
- erro de instalação com ação recomendada;
- confirmação final antes de operação destrutiva;
- tela de sucesso (“remova a ISO e reinicie”);
- export/save do `install-plan.json`.

### 8. Segurança da UI remota

Decisão recomendada:
- local/kiosk sempre ativo;
- remote UI opcional (opt-in);
- se remote ativado, gerar token curto e mostrar no TTY/UI.

Sem isso, qualquer máquina na LAN tenta mexer no installer.

## P2 — Acabamento para “distro bonita”

### 9. Plymouth logo (`branding/plymouth-logo-p4`)

Hoje: `assets/avatar/ragton.jpeg`. Trocar por `assets/branding/kryonix-logo.png`.
Critério: toplevel build + ISO build + smoke visual em VM.

### 10. System label opt-in (`branding/system-label-p5`)

```nix
kryonix.branding.systemLabel.enable = true;
```

Ativável só para hosts não-ISO que quiserem rotular como KryonixOS.

### 11. Docs de instalação final

- `docs/installer/INSTALL_KRYONIXOS.md`
- `docs/installer/TROUBLESHOOTING.md`
- `docs/installer/RELEASE_CHECKLIST.md`

Conteúdo mínimo: download ISO, gravar USB, requisitos, install VM,
install bare metal, riscos de disco, recuperar logs, reportar bug.

## Roadmap em sprints

### Sprint 1 — Externalização e target limpo

1. Merge PR #1 em `RAGton/kryonix-installer`
2. PR `installer/externalize-input-p1`
3. PR `installer/exclude-installer-from-target-p2`
4. Validar target instalado sem source do installer

### Sprint 2 — ISO release candidate

1. build ISO completo
2. boot VM
3. instalar em qcow2
4. bootar sistema instalado
5. validar branding + target flake
6. gerar relatório RC1

### Sprint 3 — Hardening

1. backend hardening P2
2. UI final error/success
3. segurança remote UI
4. CI #79 triado ou corrigido

### Sprint 4 — Polish final

1. Plymouth logo
2. docs finais
3. checksums
4. GitHub release
5. tag `v0.1.0` ou `kryonixos-rc1`

## Checklist “pronto para fechar”

- [ ] installer repo externo mergeado
- [ ] Kryonix consome installer via flake input
- [ ] source do installer não vai para target instalado
- [ ] ISO builda como artefato `.iso`
- [ ] ISO boota em VM
- [ ] UI abre no kiosk
- [ ] backend responde `/health`
- [ ] `/dry-run` passa
- [ ] install real em qcow2 passa
- [ ] sistema instalado boota
- [ ] `/etc/kryonixos` target flake funciona
- [ ] branding KryonixOS no boot/terminal/os-release
- [ ] Plymouth sem avatar pessoal
- [ ] remote UI tem regra de segurança clara
- [ ] CI release verde ou débitos documentados
- [ ] docs de instalação existem
- [ ] release checklist preenchido

## Próxima direção operacional

1. Mergear PR #1 do repo `kryonix-installer`.
2. Abrir PR 2 no motor: `installer/externalize-input-p1`.
3. Só depois voltar para Plymouth/logo.

Porque externalizar o installer e limpar o target instalado é **mais
estrutural** do que mais branding. A distro só fica “fechada” quando o
sistema instalado não carrega ferramenta de instalação como source.

## Referências cruzadas

- [[MOC - Installer]] — entrada principal do installer
- [[Target Flake v2]] — `target_tree.rs` e a denylist atual
- [[UI Flow]] — telas do installer (P1 7)
- [[Backend Routes]] — endpoints `/health`, `/dry-run`, `/install`
- [[ROADMAP]] — visão macro do projeto
- [[ACTIVE_WORK]] — trabalho em curso
- [[CURRENT_STATE]] — estado de `main` e PRs
- [[DEV PROD Flow]] — regra de ouro DEV vs PROD


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]