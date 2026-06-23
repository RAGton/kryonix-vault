---
title: "Kryonix Future Features Backlog"
type: canonical
status: draft
tags: [kryonix, backlog, features, future, planning]
created: 2026-06-23
updated: 2026-06-23
---

# Kryonix Future Features Backlog

> Features candidatas para implementação futura. Nada aqui deve ser
> implementado antes da conclusão do plano upstream/downstream atual.

---

## 1. Kernel candidates

### 1.1 CachyOS kernels

**Status:** futuro — não implementar agora
**Risco:** alto
**Área afetada:** boot, kernel, drivers, NVIDIA, ZFS, VirtualBox, libvirt

Features candidatas:

```nix
kryonix.features.kernel.cachyos.enable
kryonix.features.kernel.cachyos.bore.enable
kryonix.features.kernel.cachyos.boreLto.enable
```

**Contexto:** kernel CachyOS otimizado, especialmente `linux-cachyos-bore-lto`,
pode oferecer ganhos de performance desktop/gaming em relação ao Zen.

**Critérios antes de implementar:**

- [ ] Verificar disponibilidade no nixpkgs (packages `linuxPackages_cachyos*`)
- [ ] Ou usar overlay confiável mantido ativamente
- [ ] Validar compatibilidade com NVIDIA driver (kernel module out-of-tree)
- [ ] Validar compatibilidade com ZFS (kernel module out-of-tree)
- [ ] Validar compatibilidade com VirtualBox (kernel module out-of-tree)
- [ ] Build do toplevel com kernel CachyOS deve passar
- [ ] Testar boot em VM ou host não crítico antes de produção
- [ ] Não substituir kernel padrão automaticamente — manter opt-in
- [ ] Manter fallback de boot (systemd-boot ou GRUB com entry anterior)
- [ ] Validar que flake check passa com kernel alternativo

**Riscos específicos:**

- Kernel module signing pode quebrar com drivers NVIDIA
- Atualizações de nixpkgs podem mudar a API do kernel e quebrar módulos
- Build do kernel local pode ser lento (compensar com cache Cachix)

---

## 2. Development apps

### 2.1 Antigravity

**Status:** futuro — pesquisar antes
**Risco:** médio
**Fonte candidata:** <https://github.com/jacopone/antigravity-nix>

Features candidatas:

```nix
kryonix.features.development.antigravity.enable
kryonix.features.development.antigravityNix.enable
```

**Contexto:** O repositório `antigravity-nix` já é um flake input do Kryonix
(`flake.nix:77`). Avaliar se vale expor como feature.

**Critérios antes de implementar:**

- [ ] Auditar o flake/repo externo (jacopone/antigravity-nix)
- [ ] Verificar licença do projeto
- [ ] Verificar se baixa binários ou compila de fonte
- [ ] Validar sandbox/reproducibilidade no NixOS
- [ ] Decidir se entra como: flake input, overlay ou package local
- [ ] Verificar se há conflito com outras ferramentas de AI/dev
- [ ] Documentar uso esperado (CLI, TUI, web, app desktop?)

### 2.2 Codex Desktop

**Status:** futuro — pesquisar antes
**Risco:** médio

Feature candidata:

```nix
kryonix.features.development.codexDesktop.enable
```

**Contexto:** Codex CLI já é flake input (`github:openai/codex`). Codex Desktop
seria a versão com interface gráfica.

**Critérios antes de implementar:**

- [ ] Confirmar fonte oficial (OpenAI ou comunidade?)
- [ ] Verificar empacotamento disponível no nixpkgs
- [ ] Separar app desktop da CLI/API server
- [ ] Não misturar com secrets/API keys no repositório
- [ ] Verificar dependências (Node.js, Python, etc)
- [ ] Validar que não conflita com Codex CLI

### 2.3 Claude Desktop

**Status:** futuro — pesquisar antes
**Risco:** médio

Feature candidata:

```nix
kryonix.features.development.claudeDesktop.enable
```

**Contexto:** Claude Desktop da Anthropic como ferramenta de desenvolvimento.

**Critérios antes de implementar:**

- [ ] Confirmar fonte/empacotamento (Anthropic oficial, flatpak, nixpkgs?)
- [ ] Verificar suporte Linux/NixOS
- [ ] Não versionar credenciais ou API keys
- [ ] Separar app desktop de configuração MCP
- [ ] Verificar se requer Electron/runtime específico
- [ ] Validar que não conflita com Hermes/Aura config

---

## 3. Terminal

### 3.1 Warp Terminal

**Status:** futuro — corrigir packaging
**Risco:** baixo/médio

Features candidatas:

```nix
kryonix.features.terminal.warp.enable
kryonix.features.terminal.warp.fixPackaging
```

**Contexto:** Warp Terminal (Rust + GPU-accelerated) tem problemas de
empacotamento no NixOS atualmente.

**Critérios antes de implementar:**

- [ ] Auditar erro atual do Warp no NixOS
- [ ] Verificar se pacote vem do nixpkgs, overlay ou derivation custom
- [ ] Testar execução em NixOS puro
- [ ] Garantir que não quebre shell padrão do sistema (zsh)
- [ ] Deixar terminal padrão do sistema independente
- [ ] Verificar dependências NVIDIA/GPU
- [ ] Decidir se vale como feature ou package avulso

---

## 4. Decisão

Estas features ficam em **backlog**.

- Não implementar agora.
- Não misturar com PRs atuais de core features.

## 5. Ordem futura sugerida

1. Terminar features base do core (PRs 1-12 do plano upstream/downstream)
2. Migrar downstream por host (features.nix, features.generated.nix)
3. Ajustar installer para usar Feature Registry
4. Fechar ciclo vault: docs canônicas atualizadas
5. Só depois — abrir epic de ambiente de desenvolvimento avançado
   (antigravity, codex desktop, claude desktop, warp)
6. Só depois — testar kernels alternativos (CachyOS, XanMod)
7. Só depois — avaliar compilador LLVM para kernel

---

## 6. Links relacionados

- [[VAULT_INDEX]]
- [[02-Areas/Kryonix/canonical/UPSTREAM_DOWNSTREAM_FEATURE_ARCHITECTURE_PLAN]]
- [[02-Areas/Kryonix/canonical/FEATURE_REGISTRY]]