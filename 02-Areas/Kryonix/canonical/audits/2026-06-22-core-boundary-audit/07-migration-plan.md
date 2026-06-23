# Plano de migração — CORRIGIDO

**Nota:** Numeração harmonizada com `08-pr-backlog.md`. PRs vão de #90 a #97.

## Fase 0 — documentação (ESTA AUDITORIA)

- [x] Auditar core com evidências (ver `11-evidence-pack.md`)
- [x] Classificar cada item
- [x] Documentar no Vault
- [x] Gerar Evidence Pack com comandos reais
- [ ] Revisar com Gabriel
- [ ] Aplicar correções com base no evidence pack

## Fase 1 — remover submódulos obsoletos (PR #91, PR #92)

### PR #91: Remover submódulo `packages/kryonix-brain-lightrag`
**Evidência:** Submódulo `58d905d` vs input `95dfc2e`. Package usa `kryonix-brain-lightrag-src` do input.
- Remover diretório `packages/kryonix-brain-lightrag/`
- Validar: `nix build .#kryonix-brain-lightrag --no-link -L` (vem do input)
**Risco:** Baixo — build já usa input

### PR #92: Remover submódulo `packages/kryonix-home`
**Evidência:** Já consumido via `inputs.kryonix-home`.
- Remover diretório `packages/kryonix-home/`
- Validar: `nix build .#kryonix-home --no-link -L`
**Risco:** Baixo — build já usa input

## Fase 2 — limpeza de resíduos (PR #93)

### PR #93: Remover `hosts/inspiron/` do core
**Evidência:** `flake/data/hosts.nix` só expõe `iso`. `inspiron` não é output.
- Verificar que nenhum workflow referencia `.#nixosConfigurations.inspiron` no core
- Remover diretório `hosts/inspiron/`
- Validar: `nix flake check --keep-going`
**Risco:** Médio — docs ainda referenciam como exemplo

## Fase 3 — consolidar contextos IA (PR #94)

### PR #94: Consolidar `.ai/`, `.codex/` sem tocar em `.agents/`
**Evidência:** `.agents/` é canônico ativo. `.ai/` e `.codex/` têm conteúdo fragmentado.
- Revisar conteúdo de `.ai/` — mover o que for ativo para `docs/ai/` ou `.agents/`
- Revisar conteúdo de `.codex/` — idem
- Arquivar o restante em `docs/archive/`
**Risco:** Baixo — `.agents/` não é afetado

## Fase 4 — produtos independentes (PR #95, PR #96)

### PR #95: Separar Aura como produto
- Decidir se vira repo próprio ou feature do core
- Se mantiver no core, consolidar como serviço opcional

### PR #96: Decidir destino dos `profiles/glacier-*`
**Evidência:** São ATIVOS — downstream usa. Decisão arquitetural.
- Opção A: Manter no core como CORE_MODULE (são templates genéricos de profile)
- Opção B: Mover para downstream (cada instância define seus próprios profiles)
**Risco:** Alto se remover sem mover para downstream

## Fase 5 — Desktop Assets (PR #97)

### PR #97: Mover assets para repo separado
- Mover `assets/` (avatar, grub-theme, wallpapers PNG)
- Mover `desktop/sddm/`, `desktop/wallpapers/`
- **Manter** `desktop/hyprland/core/`, `desktop/kde/*.nix` no core (config funcional)
- Atualizar packages que referenciam assets
**Risco:** Médio — temas SDDM/wallpapers são referenciados por vários módulos

## Fase 6 — Installer/ISO (separado, dependente de decisões anteriores)

- Mover `hosts/iso/`, `modules/nixos/installer/` para `kryonix-installer`
- **Manter** `packages/kryonix-hardware-probe` no core (CORE_SHARED)
- **Manter** `packages/kryonix-disk-planner`? Debatível — é exclusivo do installer

## Rollback

Cada PR é independente e reversível com `git revert`.

## Riscos atuais (corrigidos)

1. ❌ ~~profiles glacier-*: podem ser removidos~~ → **CORRIGIDO: NÃO podem sem quebrar o downstream**
2. ❌ ~~hardware-probe vai para installer~~ → **CORRIGIDO: fica no core como CORE_SHARED**
3. ❌ ~~.agents/ é LEGACY~~ → **CORRIGIDO: é canônico ativo**
