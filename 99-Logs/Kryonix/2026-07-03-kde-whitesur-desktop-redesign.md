# Kryonix Desktop Redesign: WhiteSur-KDE

**Data**: 2026-07-03  
**Agente**: Antigravity (IA)  
**Objetivo**: Implementar o tema global WhiteSur-KDE declarativamente e remover regressões da topologia do Plasma.

## Auditoria e Diagnóstico
A query Graphify inicial e a investigação dos arquivos no repositório `kryonix` confirmaram que o sistema usava o tema "BonaFides".
- **Problema do KRunner:** O atalho nativo para KRunner é inconsistente no Plasma 6. Foi mantida a injeção via `hotkeys.commands` (atalho `Meta+A`).
- **Problema Visual:** O painel "flutuante" no topo da tela gerava uma cápsula preta opaca incompatível com o macOS/Hyprland styling, e a customização SVG nativa estava quebrando as margens.

## Solução Implementada
### 1. Pacotes NixOS Oficiais
Ao invés de rodar `fetchFromGitHub` artesanal, optamos pela abordagem segura usando a base madura e declarativa do **Nixpkgs**:
- `whitesur-kde`
- `whitesur-icon-theme`
- `nordzy-cursor-theme`
- `qtstyleplugin-kvantum` (configurado com tema `WhiteSurDark`).

### 2. Painéis Plasma Manager (Topologia macOS)
**Top Bar (Barra Fixa Superior)**:
- `floating = false` (borda a borda).
- Adicionado o Launcher Menu (kickoff) na extrema esquerda, usando o logo oficial em `/etc/kryonix/desktop/branding/kryonix/assets/logo.svg`.
- Adicionado Paginador (Workspaces).
- Removidos painéis extras instáveis. A system tray e recursos (CPU/RAM) estão centralizados aqui.

**Bottom Dock (Barra Inferior Flutuante)**:
- `floating = true`
- `autohide = true`

### 3. KWin e Blur
- Blur e Translucência assegurados em `kwin.effects`.
- Tema `WhiteSurDark` garante que as titlebars usem a paleta escurecida com vidro fosco (glassmorphism).

## Riscos e Validações
- **Build Seguro**: Foi executado apenas o build local offline (`nixos-rebuild build`) para atestar integridade.
- **Risco de Cache Sujo**: O Plasma 6 costuma mesclar (merge) arquivos de layout no `~/.config/plasmashellrc`. Ao aplicar a configuração declarativa, a topologia antiga pode causar duplicação visual ou painéis fantasmas no fundo da tela.

## Como Aplicar e Resetar (User Action Required)
Execute os comandos abaixo na sequência para evitar problemas visuais pós-deploy:

```bash
# 1. Aplica o NixOS/Home Manager
kryonix switch all

# 2. Mata o Plasma imediatamente após aplicar
kquitapp6 plasmashell

# 3. Limpa o cache de layout antigo
rm ~/.config/plasmashellrc

# 4. Reinicia a interface
kstart plasmashell
```

## Rollback
Caso queira reverter para o tema BonaFides original:
1. Faça revert do commit no repo `kryonix` (`git revert HEAD`).
2. Aplique novamente com `kryonix switch all`.
3. Repita o passo de limpar o `plasmashellrc`.
