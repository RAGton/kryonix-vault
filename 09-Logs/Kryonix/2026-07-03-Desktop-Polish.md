# Professional Desktop Polish & Antigravity

Data: 2026-07-03
Agente: Antigravity
Repos afetados:
- kryonix (core)
- kryonixos (downstream)

## Objetivo
Realizar o polimento visual definitivo do desktop Kryonix (KDE/SDDM), assegurando:
- Qualidade profissional (glass blur funcional).
- Launcher nativo Wayland elegante.
- Atalhos consistentes sem colisões perigosas.
- Integração stub declarativa do Antigravity IDE.

## Contexto consultado
- Revisão do FrameSVG e limitações do KDE na construção manual de bordas com blur (ver log anterior: `2026-07-03-KDE-Theme-Rebuild.md`).
- Consulta aos presets do KWin (`translucency`, `blur`), Fuzzel configs e configs SDDM QML.
- Regras estritas de quebra/fallback via `metadata.json` para componentes KDE (`X-Plasma-FallbackTheme`).

## Mudanças realizadas
1. **Fallback do Tema KDE**: Para garantir 100% de precisão e mitigar riscos do fallback nativo do KDE Plasma falhar em carregar os metadados SVG, copiamos os componentes `panel-background.svg` e `background.svg` do tema base (BonaFides) diretamente para a pasta de artefatos do nosso tema.
2. **KWin Translucency**: Desativamos o plugin global de `translucency` (`kwin.effects.translucency.enable = false`) para evitar que janelas de aplicativos comuns fiquem ilegíveis com transparência forçada, mantendo o `blur` ativado para as superfícies que o solicitam (painéis e dock).
3. **Fuzzel (Launcher)**: Trocamos o navy sólido opaco por `#0b1017aa` (navy ~66%), transformando o Fuzzel em uma superfície "Dark Glass" que emula perfeitamente a estética Spotlight/Hyprland. Atalho migrado para `Meta+Space`.
4. **SDDM**: Revisamos o contraste no cartão de login do preset `kryonix-clean`. Definido `color: "#b30b1017"` (dark navy 70%) com borda accent azul 35% `#5938bdf8`, mitigando visuais estranhos em telas sem suporte a blur no compositor de login.
5. **System Tray & Dock**: `blueman` foi desativado downstream em `glacier/bluetooth.nix` para evitar redundância na bandeja do sistema, deixando o `bluedevil` do próprio KDE cuidar de tudo com maestria. Ícones estáticos cruciais adicionados à dock (Chrome, Edge, Steam, Antigravity).
6. **Keybinds**: `Meta+L` foi convertido para `Lock Screen` (bloquear), substituindo o comportamento perigoso de `suspend` (agora remapeado para `Meta+Shift+Escape`).
7. **Antigravity IDE**: Adicionado como um stub via `kryonix.features.development.antigravity` no NixOS, exibindo um `lib.mkWarning` para sinalizar falta de binário/AppImage oficial empacotado. Preparado para a P1.

## Commits e branches
**kryonix:**
- `style(kde): inherit bonafides plasma assets for kryonix theme`
- `style(kde): refine fuzzel/krunner dark glass launcher`
- `style(sddm): polish kryonix clean login theme`
- `fix(kde): normalize tray icons and desktop entries`
- `feat(kde): refine professional shortcuts`
- `feat(development): add antigravity ide integration stub`

**kryonixos:**
- `fix(bluetooth): remove redundant blueman applet to prevent tray duplicates`

**kryonix-dev:**
- `chore(dev): update submodules for professional desktop polish`
- `chore(dev): update vault submodule pointer for desktop polish log`

## Validações executadas
- Dry-run build do NixOS top level para o host `inspiron` ocorreu com sucesso (`--dry-run --show-trace`).
- Git diffs validados contra o design system.

## Evidências
- Todo o código foi injetado de forma declarativa e seguindo boas práticas Nix (usando stubs no lugar de `/opt` ad-hoc).

## Pendências
- Obter a fonte/hash oficial do Google Antigravity IDE (quando disponível/estável) para criar a derivation real via `appimageTools.wrapType2`.

## Próximo passo recomendado
- Acompanhar release notes do Antigravity para preencher o stub, ou continuar refinando fluxos com o Aura Agent.
