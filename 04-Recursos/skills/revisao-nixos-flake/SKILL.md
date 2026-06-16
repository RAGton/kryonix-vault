---
title: revisao-nixos-flake
type: skill
status: stub
tags: [skill, nixos, flake, revisao]
purpose: Revisar mudanças em flakes NixOS antes de aplicar ou mesclar
---

# revisao-nixos-flake

## Objetivo

Revisar mudanças em `flake.nix`, `flake.lock` e módulos NixOS antes de aplicar (`nixos-rebuild`) ou mesclar PR, identificando regressões, deriva de inputs, problemas de segurança e oportunidades de simplificação.

## Resumo

Stub criado durante a reorganização do vault (Fase 2, 2026-06-15). Conteúdo operacional a ser preenchido.

## Quando usar

- Antes de abrir PR que toque em qualquer arquivo `.nix` ou `flake.lock`.
- Antes de rodar `nixos-rebuild switch` em ambiente crítico.
- Ao revisar PR de outro engenheiro em projeto NixOS.

## Quando não usar

- Não usar para revisar código de aplicação (Rust, Python, etc) — para isso existe `revisao-pr`.
- Não usar para auditoria de segurança ampla — para isso existe `auditoria-secrets` e `revisao-seguranca-api`.

## Input esperado

- Diff do PR ou patch proposto.
- Conteúdo de `flake.nix`, `flake.lock` (mudanças), módulos afetados.
- Contexto do host/perfil alvo.

## Output esperado

- Lista priorizada de riscos (alto/médio/baixo).
- Veredito: APROVAR / APROVAR COM RESSALVAS / BLOQUEAR.
- Ações concretas antes de merge/deploy.

## Procedimento

1. Verificar se `flake.lock` mudou e listar inputs alterados (versões).
2. Rodar `nix flake check` e `nix flake show` no diretório do flake.
3. Conferir se módulos novos declaram opções em `mkOption` com `type` e `default` explícitos.
4. Procurar `builtins.fetchurl`, `builtins.fetchTarball`, `fetchGit` sem hash — risco de supply chain.
5. Conferir secrets: nada de `builtins.fetchTree` apontando para repo privado sem `narHash`, nada de chave inline.
6. Avaliar impacto em sistemas já deployados: `nixos-rebuild dry-build` ou `nix build .#nixosConfigurations.<host>.config.system.path`.
7. Listar overlays adicionadas e se foram testadas com `nix flake check --override-input ...`.
8. Verificar licença de inputs novos e se respeitam a policy do projeto.

## Checklist

- [ ] `flake.lock` mudado? Listar inputs.
- [ ] `nix flake check` passou sem warnings críticos?
- [ ] Sem `builtins.fetch*` sem hash?
- [ ] Sem secrets em texto puro?
- [ ] Módulos NixOS novos têm `mkOption` tipado?
- [ ] Overlays testadas isoladamente?
- [ ] `dry-build` do host alvo passou?

## Riscos

- Mudança em `flake.lock` pode regredir builds em todo o sistema — sempre rodar `nix flake check` antes de aprovar.
- Inputs não pinados (refs flutuantes) podem introduzir deriva não determinística.
- Avaliação Nix pode falhar silenciosamente se faltar `meta.description` ou `meta.maintainers`.

## Token-saving mechanism

Skill carrega contexto fixo (checklist de NixOS) e evita repetir comandos longos no prompt. Procedimento em 8 passos curtos em vez de texto livre.

## Base prompt

```txt
Atue como revisor sênior de flakes NixOS. Aplique o procedimento
definido em [[04-Recursos/skills/revisao-nixos-flake/SKILL]] ao
diff abaixo. Produza veredito (APROVAR/APROVAR COM RESSALVAS/BLOQUEAR)
e lista priorizada de ações.
```

## Links relacionados

- [[02-Areas/NixOS/Flakes]]
- [[02-Areas/NixOS/Modulos NixOS]]
- [[04-Recursos/skills/revisao-pr]]
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
- [[04-Recursos/prompts/Prompt - Revisao NixOS]]
- [[04-Recursos/prompts/Prompt - Criacao de Flake]]

## Próxima ação

Preencher exemplos reais de revisão (PRs passados do Kryonix).
