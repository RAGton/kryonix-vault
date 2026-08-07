---
theme: kryonix-carbon
target_profile: server
status: DRAFT v0 — UNTESTED (não carregado em Plasma/Kvantum/Aurorae real)
date: 2026-08-07
agent: Aura
repo: repos/kryonix (packages/themes/)
---

# Kryonix Carbon — Design Rationale

## Identidade

Server-grade, industrial, hacker. Âmbar sobre preto profundo.

## Cor accent

`#FF9F0A` (âmbar Kryonix) — não é azul Apple, não é verde Linux. Diferencia a distro visualmente.

## Tokens compartilhados

Tudo em `packages/themes/tokens/` (consumido por Carbon e Eclipse):

- `palette-base.nix` — escala neutra profunda (bg-base `#0A0A0A`, surface `#161616`, ...)
- `typography.nix` — Inter como família padrão (weights 400/500/600)
- `spacing.nix` — múltiplos de 4px (4/8/12/16/24/32/48/64)
- `radius.nix` — `radiusSm=4` (Carbon) vs `radiusLg=12` (Eclipse)

## Quando usar

- `kryonix.profiles.server.enable = true`
- Headless server, workstation dev, infra ops
- **Default** se nenhum profile explícito (Carbon é o safe default)

## Quando NÃO usar

- Desktop pessoal interativo longo, design/creative work — preferir **Eclipse** (FASE 2)
- Ambientes onde usuários esperam affordances visuais Apple-like

## Não usa

- Translucência (overhead, lento em servidor)
- Animações decorativas
- Cantos muito arredondados (radius 4 max → `radiusSm`)

## Estrutura do package

```
packages/themes/
├── tokens/                       # compartilhado com Eclipse (FASE 2)
│   ├── default.nix               # aggregator
│   ├── palette-base.nix
│   ├── typography.nix
│   ├── spacing.nix
│   └── radius.nix
└── kryonix-carbon/
    ├── default.nix               # derivação Nix (stdenvNoCC, multi-format)
    ├── palette.nix               # accent âmbar + overrides sobre tokens
    ├── plasma/
    │   └── KryonixCarbon.colors  # Plasma 6 color scheme (~60 entries)
    ├── kvantum/
    │   └── kvantum.kvconfig      # Kvantum theme config
    ├── aurorae/
    │   └── KryonixCarbon/
    │       └── metadata.json     # KPlugin org.kde.kdecoration2
    └── splash/                   # placeholder p/ FASE 2
```

Padrão de derivação segue `packages/bonafides-theme.nix` (modelo canônico do core).

## Como aplicar (quando Gabriel for integrar)

```nix
# desktop/kde/theme.nix (futuro)
{ kryonix-carbon }:
{
  environment.packages = [ kryonix-carbon ];
  # workspace.lookAndFeel quando look-and-feel for adicionado
  # workspace.auroraeTheme = "kryonix-carbon";
  # workspace.theme = "KryonixCarbon";
}
```

## Status atual (FASE 1, 2026-08-07)

- ✅ Estrutura de pastas criada
- ✅ Tokens compartilhados escritos
- ✅ `kryonix-carbon/default.nix` + paleta
- ✅ `plasma/KryonixCarbon.colors` (DRAFT — não carregado em Plasma)
- ✅ `kvantum/kvantum.kvconfig` (DRAFT — não testado)
- ✅ `aurorae/KryonixCarbon/metadata.json` (JSON válido, sem assets ainda)
- ⏳ `splash/` vazio (FASE 2)
- ❌ `plasma/desktoptheme/KryonixCarbon/` (FASE 2 — SVG widgets, panels)
- ❌ `plasma/look-and-feel/` (FASE 2 — global theme XML)
- ❌ Wallpaper alinhado ao accent (FASE 2 — kryonix-assets/)
- ❌ Integração em `desktop/kde/theme.nix` (FASE 2)

## Validação executada

- `git status` no `repos/kryonix` — alterações isoladas em `packages/themes/`
- JSON lint do `metadata.json` — OK
- `nix flake check` — **NÃO executado** (escopo do plano era só criar arquivos; validação fica pra commit)
- Runtime Plasma/Kvantum/Aurorae — **NÃO executado** (sem host GUI ativo nesta sessão)

## Pendências

1. Validar `nix flake check` antes do primeiro commit
2. Smoke test com `plasma-apply-colorscheme KryonixCarbon` num host real
3. Criar SVG widgets do desktoptheme
4. Definir hook com `kryonix.profiles.server.enable` em `modules/profiles/`
5. Decidir integração via `kryonix-assets` ou self-contained (preferência: self-contained por enquanto)

## Próximo passo (FASE 2)

- **kryonix-eclipse** — mesma estrutura, paleta azul Apple-like, radius 12, splash
- Desktoptheme SVG (componentes Plasma 6)
- Integração em `desktop/kde/theme.nix` com switch via `kryonix.profiles.{server,desktop}.enable`

## Links relacionados

- [[VAULT_INDEX]] — hub principal
- [[02-Areas/Kryonix/canonical/Architecture]] — arquitetura geral Kryonix
- [[02-Areas/Kryonix/canonical/CORE_DOWNSTREAM_INSTALLER]] — separação core/host/installer
- `packages/bonafides-theme.nix` (repo `repos/kryonix`) — referência canônica de derivação multi-formato
- `packages/themes/kryonix-carbon/` (repo `repos/kryonix`) — implementação

## Riscos

- **Risco técnico**: Plasma 6 pode ter rejeitado campos legados do `<Color>` XML — validação obrigatória antes de declarar produção.
- **Risco arquitetural**: theme no `packages/` mas ativado via `modules/profiles/` ainda não existe. Pode ser que `kryonix.profiles.*` precise virar feature opt-in primeiro.
- **Risco de duplicação**: existe `packages/kryonix-plasma-theme.nix` (Blue Glass, legado). Não conflita agora mas decisão de sunset deve ser tomada em FASE 2.

#tags: kryonix/canonical kryonix/theme kryonix/design-system kryonix/profile/server status/draft