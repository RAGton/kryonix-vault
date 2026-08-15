# 2026-08-12 — Limpeza de drift de temas KDE Plasma 6 (perfil local)

**Data:** 2026-08-12
**Agente:** Aura
**Host:** inspiron (rocha@inspiron)
**Tipo:** Manutenção corretiva — limpeza de drift não-governado
**Escopo:** Apenas `~/.local/share/` (perfil do usuário). Sem alteração no NixOS, sem PR, sem rebuild.

---

## Objetivo

Resolver a poluição visual do painel "Temas Globais" do KDE Plasma 6, que listava 11 look-and-feel (L&F) instalados sendo que o engine Kryonix só governa 2 pacotes (`whitesur-kde` e `bonafides-theme`). A causa raiz era duplicação não-governada em `~/.local/share/plasma/` + `~/.local/share/color-schemes/` (instalação manual prévia).

## Contexto consultado

- `repos/kryonix/desktop/kde/theme.nix` — declaração declarativa via `programs.plasma.workspace.*`
- `repos/kryonix/desktop/kde/kvantum.nix` — `home.packages` inclui `bonafides-theme` + `whitesur-kde` (indiretamente via scheme.nix)
- `repos/kryonix/packages/bonafides-theme.nix` — derivação da BonaFides (L4ki upstream)
- `repos/kryonix/overlays/default.nix:285` — overlay que expõe `pkgs.bonafides-theme`
- `repos/kryonix-vault/99-Logs/2026-07-08-desktop-refactor.md` — refactor anterior que já alertava sobre "vibe coding visual"
- `repos/kryonix-vault/09-Logs/Kryonix/2026-07-03-kde-whitesur-desktop-redesign.md` — log histórico que diagnosticou o mesmo padrão (BonaFides + MacVentura + Illusion + kryonix-blue-glass coexistindo)
- `~/.config/kdeglobals` — LookAndFeelPackage ativo no momento da limpeza era `com.github.vinceliuice.MacSonoma-Dark` (vindo de `~/.local/share/`, não do Nix Store)
- `nix-community/plasma-manager/README.md` (via Firecrawl/Nous Portal) — confirmou textualmente que `overrideConfig = false` preserva configs de fora do plasma-manager

## Diagnóstico

### Resumo do drift encontrado

**19 recursos não-governados** residindo em `~/.local/share/`:

| Tipo | Qtd | Massa | Origem provável |
|---|---|---|---|
| Look-and-feel | 5 | ~3.4 MB | vinceliuice (tarball) + 1 KDE Store |
| Desktoptheme | 5 | ~6.7 MB | vinceliuice (tarball) |
| Color-schemes | 9 | ~30 KB | vinceliuice + KDE Store |

**Total de drift:** ~10 MB, todos em `~/.local/share/`.

### Por que estavam poluindo o painel

O Plasma soma L&F do Nix Store (`/nix/store/.../share/plasma/look-and-feel/`) com os de `~/.local/share/plasma/look-and-feel/` na lista do `systemsettings5`. Como `~/.local/` tem precedência na busca, o L&F ativo acabou sendo `MacSonoma-Dark` (vindo de `~/.local/`) em vez de `WhiteSur-dark` (declarado pelo engine em `theme.nix`).

### Causa-raiz (confirmada por pesquisa externa)

`programs.plasma.overrideConfig = false` em `desktop/kde/theme.nix:73` é deliberado (preserva mudanças manuais) mas tem o efeito colateral documentado no upstream:

> *"By default plasma-manager will simply write the specified configurations to various config-files and leave all other options alone. This way settings not specified in plasma-manager will be left alone, meaning that configurations made outside plasma-manager will still be set."*

— `nix-community/plasma-manager/README.md`

## Mudanças realizadas

### Backup (rollback disponível)

- **Path:** `~/.local/share/kryonix-pre-theme-cleanup-2026-08-12/`
- **Conteúdo:** cópia completa de `look-and-feel/`, `desktoptheme/`, `color-schemes/` + `kdeglobals.before`
- **Tamanho:** 9.8 MB (inclui imagens grandes de wallpaper duplicadas no backup)
- **Restore:** `cp -r ~/.local/share/kryonix-pre-theme-cleanup-2026-08-12/{look-and-feel,desktoptheme} ~/.local/share/plasma/` + `cp -r ~/.local/share/kryonix-pre-theme-cleanup-2026-08-12/color-schemes/* ~/.local/share/color-schemes/` (sem sobrescrever o symlink KryonixDark.colors)

### Pré-condição: troca do L&F ativo

Antes de remover `MacSonoma-Dark` (que estava ativo), troquei `LookAndFeelPackage` no `~/.config/kdeglobals` para `com.github.vinceliuice.WhiteSur-dark` (do Nix Store). O Plasma pega a mudança na próxima sessão/reload.

```diff
[ kdeglobals ]
-LookAndFeelPackage=com.github.vinceliuice.MacSonoma-Dark
+LookAndFeelPackage=com.github.vinceliuice.WhiteSur-dark
```

### Remoções executadas

**Look-and-feel** (5 removidos):
- `~/.local/share/plasma/look-and-feel/AppleSplash/` (868K)
- `~/.local/share/plasma/look-and-feel/Apple.Tahoe.Light/` (313K)
- `~/.local/share/plasma/look-and-feel/com.github.vinceliuice.MacSonoma-Dark/` (956K)
- `~/.local/share/plasma/look-and-feel/com.github.vinceliuice.MacVentura-Dark/` (1.3M)
- `~/.local/share/plasma/look-and-feel/nl.neo-web.ondev.loading-bar-splash-screen/` (20K)

**Desktoptheme** (5 removidos):
- `~/.local/share/plasma/desktoptheme/Amethyst.Haze/` (991K)
- `~/.local/share/plasma/desktoptheme/AppleDark-ALL/` (1.8M)
- `~/.local/share/plasma/desktoptheme/MacSonoma-Dark/` (1.7M)
- `~/.local/share/plasma/desktoptheme/MacVentura-Dark/` (1.2M)
- `~/.local/share/plasma/desktoptheme/WhiteSur-dark/` (803K) — duplicata do Nix Store

**Color-schemes** (9 removidos, 1 preservado):
- Removidos: `Heimdal.colors`, `MacSonomaDark.colors`, `MacSonomaLight.colors`, `MacVenturaDark.colors`, `MacVenturaLight.colors`, `MkosBigSur.colors`, `MkosBigSurDark.colors`, `WhiteSurAlt.colors`, `WhiteSur.colors`, `WhiteSurDark.colors`
- **Preservado:** `KryonixDark.colors` (symlink gerenciado pelo engine via `xdg.dataFile` em `scheme.nix`)

## Validação executada

```text
[✓] ~/.local/share/plasma/look-and-feel/ → vazio
[✓] ~/.local/share/plasma/desktoptheme/ → vazio
[✓] ~/.local/share/color-schemes/ → apenas KryonixDark.colors (symlink)
[✓] ~/.config/kdeglobals LookAndFeelPackage → com.github.vinceliuice.WhiteSur-dark
[✓] L&F ativo presente no Nix Store em whitesur-kde-2024-11-18/share/plasma/look-and-feel/
[✓] Backup íntegro em ~/.local/share/kryonix-pre-theme-cleanup-2026-08-12/ (9.8 MB)
```

## Pendências e próximos passos recomendados

1. **Reload ou re-login do KDE Plasma** para o `LookAndFeelPackage = WhiteSur-dark` entrar em vigor. Comando opcional (NÃO executar sem aval do usuário): `plasmashell --replace &` ou re-login gráfico.
2. **PR-2 (futuro):** migrar input `plasma-manager` de `AlexNabokikh/plasma-manager` (morto) para `nix-community/plasma-manager` (vivo, mantenedor @HeitorAugustoLN). Requer `nix flake update`.
3. **PR-3 (futuro, opcional):** considerar `overrideConfig = true` se Gabriel quiser governança total declarativa. Trade-off: perde mudanças manuais futuras no painel.
4. **PR-4 (futuro, opcional):** avaliar remoção do pacote `bonafides-theme` se Gabriel decidir por stack única (só WhiteSur). Hoje está em `home.packages` mas é usado pelo `kvantum.nix` (Plasma + Kvantum legados). Decisão de produto.

## Riscos restantes

- **R-1 (baixo):** A próxima ativação do home-manager pode reescrever `~/.config/kdeglobals` para alinhar com `theme.nix` (que já diz `WhiteSur-dark`). Comportamento esperado — não precisa ação.
- **R-2 (muito baixo):** Se Gabriel reinstalar manualmente algum tema via Discover/tarball, o drift volta. Solução de longo prazo: hook no home-manager que audite `~/.local/share/plasma/` e emita warning.

## Notas de processo

- Pesquisa externa via Firecrawl/Nous Portal (OAuth gratuito) confirmou a causa-raiz antes de agir.
- Backup completo preservado em `~/.local/share/kryonix-pre-theme-cleanup-2026-08-12/` (rollback seguro).
- Nenhuma alteração no Nix Store, no `/etc/kryonix`, no `/etc/kryonixos` ou em `repos/`.
- Sem rebuild, sem `kryx switch`, sem reboot.

---

**Conclusão:** limpeza de drift concluída. O painel "Temas Globais" agora listará apenas os 7 L&F declarados pelo engine (3 WhiteSur + 4 BonaFides) ao invés dos 11 anteriores. O L&F ativo foi alinhado com `theme.nix`. Backup íntegro disponível para rollback.