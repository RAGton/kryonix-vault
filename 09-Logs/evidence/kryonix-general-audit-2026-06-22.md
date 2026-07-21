---
tipo: evidence
projeto: kryonix
componente: auditoria-geral
created: 2026-06-22
updated: 2026-06-22
author: aura
tags: [auditoria, estado-geral, repos, branches, prs]
---

# Auditoria geral Kryonix — 2026-06-22

## Objetivo

Mapear o estado real de todos os repositórios, worktrees, branches e PRs do ecossistema Kryonix para permitir decisão informada sobre próximo passo.

## Resumo executivo

```
Estado geral: 8 paths auditados, 3 branches contaminadas (corrigidas), 1 worktree com patch pendente,
4 PRs relevantes abertos (todos Draft), 1 downstream funcionando, 1 erro nixfmt pré-existente.
```

### Estado por repo

| Repo | Branch | Estado | Trabalho pendente |
|---|---|---|---|
| **motor DEV** (`kryonix`) | `feat/browser-automation` | Suja (remotos NÃO minhas + untracked) | PR #87 limpo; installer sujo da branch anterior |
| **downstream DEV** (`kryonixos/`) | `main` | Suja (1 arquivo) | `hosts/glacier/live.nix` modificado |
| **installer DEV** (`kryxd`) | `main` | Muito suja (17+ arquivos, ahead 7) | Background3D, theme, patches |
| **worktree UI** (`kryxd-ui-refine`) | `ui/refine-legibility` | 1 arquivo modificado | Patch B parcial, Patch C não iniciado |
| **worktree clean** (`kryonix-browser-automation-clean`) | `feat/browser-automation-clean` | Limpa | Só existe para validar PR #87 |
| **Vault** (`kryonix-vault`) | `main` | 1 commit ahead; .obsidian sujo | PR log, skills, livres |
| **motor PROD** (`/etc/kryonix`) | — | Acesso proibido (root) | Não auditável por rocha |
| **downstream PROD** (`/etc/kryonixos`) | `main` | Limpa | Build OK sem override |

## PRs abertos relevantes

| Repo | PR | Branch | Draft | MergeStatus | Risco |
|---|---|---|---|---|---|
| kryonix | **#87** (browser-automation) | feat/browser-automation | Draft | UNSTABLE | ✅ **LIMPO** — 3 files, 1 commit, sem contaminação |
| kryonix | **#86** (remote-web-boot) | feat/remote-web-boot-mode | Draft | UNSTABLE | ⚠️ 4 commits, 2 files (iso + installer/web-kiosk) |
| kryonix | **#69-55** (arquivados) | archive/* | Draft | DIRTY/UNSTABLE | 💤 PRs históricos, sem impacto |
| kryxd | Nenhum | — | — | — | Nenhum PR aberto |

## Branches e contaminações

### feat/browser-automation (PR #87)

```
Antes da limpeza: 11 arquivos (contaminada com remote-web-boot)
Depois da limpeza: 3 arquivos ✅
  M hosts/inspiron/default.nix
  A modules/nixos/features/browser-automation.nix
  M modules/nixos/features/default.nix
Sem flake.nix/flake.lock no diff ✅
```

### feat/browser-automation-clean (local, não existe no remote)

```
1 commit (b60322f2) contra origin/main, mesmos 3 arquivos.
Worktree auxiliar mantida por segurança.
```

### feat/remote-web-boot-mode (PR #86)

```
4 commits contra origin/main, 2 arquivos
  M hosts/iso/default.nix
  M modules/nixos/installer/web-kiosk.nix
Sem flake.nix/flake.lock no diff ✅
Não contaminada pela browser-automation.
```

## Working trees sujas

| Path | Branch | Mudanças |
|---|---|---|
| `kryxd-ui-refine` | `ui/refine-legibility` | `ui/src/index.css` (+9/-1) — Patch B parcial |
| `kryonix/.worktrees/installer-polish-p1` | `installer-polish-p1` | (não auditado em detalhe) |
| `kryonix-browser-automation-clean` | `feat/browser-automation-clean` | Limpa — removível após merge do PR #87 |

## Arquivos untracked relevantes

| Repo | Arquivo | Observação |
|---|---|---|
| kryonix | `run_qemu.exp` / `run_qemu.py` / `run_vm_console.py` | Scripts de teste ISO do remote-web-boot |
| kryonix | `.worktrees/` | Worktree residual |
| kryonix | `test-specialisation.nix` | Teste não comitado |
| kryonix | `pr-body.md` | PR body temporário |
| kryxd | `test_hash*` | Artefato de teste |
| kryxd | `ui/clean_jsx.*`, `*_theme.py` | Scripts auxiliares |
| kryonix-vault | `04-Recursos/livros/` | PDFs (gitignorados?) |

## Arquivos sensíveis detectados

```
Vault: .obsidian/graph.json e .obsidian/workspace.json modificados (pré-existente, sem risco)
Demais: nenhum secret/token/key no status tracked
```

## Estado do PR #87

```
Número: 87
Estado: OPEN / Draft
Branch: feat/browser-automation (remoto, limpo)
Base: main
Commits: 1 (b60322f2)
Arquivos: 3 (hosts/inspiron/default.nix, modules/nixos/features/browser-automation.nix, modules/nixos/features/default.nix)
Merge status: UNSTABLE (nixfmt check, pré-existente)
Review: nenhum
Pode sair de Draft? SIM (tecnicamente limpo)
```

## Estado do PR #86 (Remote Web Boot Mode)

```
Número: 86
Estado: OPEN / Draft
Branch: feat/remote-web-boot-mode
Base: main
Commits: 4
Arquivos: 2 (hosts/iso/default.nix, modules/nixos/installer/web-kiosk.nix)
Merge status: UNSTABLE
Sem contaminação cruzada com PR #87 ✅
```

## Estado da worktree UI installer

```
Path: /home/rocha/kryonix/kryxd-ui-refine
Branch: ui/refine-legibility
HEAD: 2ec0336 (mesmo do main do installer)
Mudanças: apenas ui/src/index.css (9 linhas modificadas)
Patch B (tipografia): parcialmente aplicado (font-family, --text2, line-height)
Patch C (Install.jsx erro colapsável): NÃO INICIADO
```

## Estado do Vault

```
Branch: main
Commit: 60f1e41 (PR #87 log)
Ahead: 1 (não pusheado)
Sujo: .obsidian/* (pré-existente) + 04-Recursos/livros/ (untracked)
Skills de vibe coding: 8 skills criadas, todas ativo_revisao_pendente
Templates de vibe coding: 7 templates
Logs: PR-087 registrado
```

## Estado do downstream /etc/kryonixos

```
Branch: main (limpo, sem dirty)
HEAD: 2e60720 (2026-06-09)
Motor usado: /etc/kryonix (rev c8c7f8c8, 2026-06-09)
NÃO tem browser-automation feature (só entra quando o PROD motor for atualizado)
Build: OK (nix build passou)
```

## Estado do downstream local /home/rocha/kryonix/kryonixos

```
Repositório local mesma ref do /etc/kryonixos. 1 arquivo dirty (hosts/glacier/live.nix).
Provavelmente criado para edição local fora do /etc. Precisa confirmar propósito.
```

## Checks Nix

| Check | Resultado |
|---|---|
| `nix flake check` (DEV) | FALHOU — `checks.x86_64-linux.formatting` pré-existente (nixfmt) |
| `nix build` (downstream PROD) | ✅ PASS — sem override |
| `nix build` (downstream + override DEV) | ❌ FALHOU — conflito de versão do home-manager entre DEV e PROD |

## Riscos críticos

| Risco | Severidade | Situação |
|---|---|---|
| Installer DEV com 17+ arquivos sujos, ahead 7, sem PR | **ALTO** | Pode perder trabalho se houver merge/reboot sem commit |
| Motor DEV working tree suja com mudanças da `feat/remote-web-boot-mode` | **MÉDIO** | Commit do browser-automation está limpo, mas working tree carrega sujeira da branch anterior |
| `nixfmt` check quebrando flake check | **MÉDIO** | Impede CI de passar; precisa de PR separado para corrigir |
| Downstream local (`kryonixos/home`) com glacier/live.nix dirty | **BAIXO** | Host glacier é para outro computador (servidor) |
| Vault ahead 1 não pusheado | **BAIXO** | Não é urgente, mas pode perder log do PR #87 se HD falhar |
| /etc/kryonix não auditável por permissão | **BAIXO** | Acesso root requerido; git pode estar em estado diferente |
| PR #87 merge status UNSTABLE por nixfmt | **BAIXO** | Não é bloqueante para merge (erro pré-existente fora do escopo) |

## Recomendações

### Fazer agora (curto prazo)

1. **Finalizar patches B e C da UI installer na worktree** — Patch B parcial, Patch C não iniciado. É o trabalho mais próximo de conclusão.
2. **Resolver PR #87:** tirar de Draft e mergear OU decidir esperar nixfmt ser corrigido.
3. **Registrar auditoria no Vault** — este relatório (não commitar antes da revisão).

### Fazer depois (médio prazo)

4. **Limpar sujeira do installer DEV** — 17+ arquivos sujos, precisa de commit e PR.
5. **Corrigir nixfmt pré-existente em PR separado** — desbloqueia flake check para todos os PRs futuros.
6. **Remover worktrees residuais** (`installer-polish-p1`, `browser-automation-clean` após PR #87 merge).
7. **Comitar relatórios do Vault e push**.
8. **Validar downstream com override após PR #87 merge** — testar se browser-automation avalia com home-manager correto.

### Não fazer

9. **Não mexer em archive PRs** (#55, #65-69) — são preservações históricas, sem impacto.
10. **Não mexer em glacier/live.nix** sem contexto do host remoto.
11. **Não fazer merge de PR #86 (remote-web-boot)** sem revisão separada.
12. **Não tentar resolver contaminação do motor DEV editando working tree** — só fazer branch nova e cherry-pick se necessário.

## Plano de saneamento proposto

```txt
1. Finalizar ui/refine-legibility (Patch B completo + Patch C)
2. Rodar testes npm no installer
3. Se PR #87 for mergear: tirar de Draft, mergear, limpar worktree
4. Reavaliar se browser automation precisa de rebuild (nixos-rebuild switch)
5. Só depois: fechar outras pendências (nixfmt, glacier, vault push)
```

## Confirmações de segurança

- [x] Nenhum switch executado
- [x] Nenhum rebuild executado
- [x] Nenhum merge executado
- [x] Nenhum push executado (exceto o autorizado para PR #87)
- [x] Nenhum pull executado
- [x] Nenhum arquivo removido/movido
- [x] Nenhum resolver automático
- [x] Nenhum .obsidian tocado
- [x] /etc/kryonix e /etc/kryonixos só lidos