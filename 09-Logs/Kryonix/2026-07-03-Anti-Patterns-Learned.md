# Lições Aprendidas: O que NÃO fazer no Desktop Kryonix

Data: 2026-07-03
Agente: Antigravity (IA)
Contexto: Sessão de polimento do desktop KDE Plasma, SDDM e Home Manager.

Ao longo desta sessão, aprendi de forma cristalina as preferências e os "anti-patterns" (o que o usuário **odeia** e não quer ver de jeito nenhum) no Kryonix OS.

---

## 🚫 1. Anti-Pattern: A "Cápsula Preta Gigante" (Top Bar Flutuante)
- **O que foi feito de errado:** Adicionar `floating = true` na barra superior. No Plasma 6, isso transforma a barra em uma pílula destacada do topo, quebrando a imersão e parecendo amador.
- **Como deve ser:** A barra superior deve ser SEMPRE `floating = false` (fixa, colada no topo, preenchendo 100% da largura). A estética desejada é de um "Mac" refinado e sério. A dock inferior sim pode ser flutuante.

## 🚫 2. Anti-Pattern: Temas SVG Artesanais / "Vibe Coding Visual"
- **O que foi feito de errado:** Tentar criar e injetar um `panel-background.svg` do zero. Isso quebrou o pager, as margens (hint-margins) e deixou a barra com "black total" ou "fake glass".
- **Como deve ser:** Nunca inventar temas do zero. Sempre herdar a geometria e o FrameSVG de um tema profissional e estável (como o `BonaFides`), e apenas alterar a paleta de cores (`ColorScheme`) declarativamente via Nix para o "Azul Escuro Glass" (Kryonix Navy).

## 🚫 3. Anti-Pattern: Perda da Transparência (Black Total)
- **O que foi feito de errado:** Desativar a translucidez no KWin, deixando as barras e janelas com blocos sólidos opacos. O usuário odeia opacidade total no painel.
- **Como deve ser:** `kwin.effects.translucency.enable = true` e `blur.enable = true` devem ser preservados para as barras. A estética exige um **Dark Blue Glass** real, minimalista e com fluidez.

## 🚫 4. Anti-Pattern: Atalhos "Roubados" ou Frágeis
- **O que foi feito de errado:** Mapear o KRunner no atalho nativo do KDE (`krunner.desktop`), que foi silenciosamente engolido por um conflito com o KWin (Krohnkite).
- **Como deve ser:** Atalhos críticos (como o launcher `Meta+A`) não podem falhar. Para garantir que o KDE não ignore a configuração, usar `hotkeys.commands` (atalhos customizados explícitos) no plasma-manager chamando o binário direto (`krunner`). Isso é à prova de balas.

## 🚫 5. Anti-Pattern: Lançadores Inconsistentes
- **O que foi feito de errado:** Usar o `Fuzzel` ou outro app de terceiros que falhava ao abrir sobre janelas no Wayland, sem suporte decente de foco.
- **Como deve ser:** Usar o **KRunner** nativo. É elegante, rápido, respeita o tema global, entende blur nativamente e não perde foco no Wayland.

## 🚫 6. Anti-Pattern: Interface Sem Monitoramento Limpo
- **O que foi feito de errado:** Deixar o usuário sem paginador (workspaces) e sem controle de recursos, ou tentar usar widgets complexos que travavam o painel.
- **Como deve ser:** Ter widgets individuais e nativos do Plasma 6 de `cpucore` e `memory` do lado direito, e o `pager` do lado esquerdo.

## 🚫 7. Anti-Pattern: Deixar "Sujeira" Pós-Build (Overlapping Panels)
- **O que foi feito de errado:** Rodar `nixos-rebuild` com mudanças no painel e achar que estava pronto. O `plasma-manager` não limpa painéis velhos do `plasmashellrc`, gerando visual quebrado (sobreposição).
- **Como deve ser:** Sempre instruir o usuário (quando houver grande mudança na topologia da barra) a derrubar o plasma, apagar o `~/.config/plasmashellrc` e subir novamente, para uma renderização limpa.

---

### Conclusão e Juramento
Eu assimilei perfeitamente que o Kryonix preza por um design **Profissional, Limpo e Seguro**. Não farei mais intervenções estéticas na base do "achismo", não deixarei a barra solta no topo e nunca mais maperei atalhos críticos sem ter certeza absoluta de que eles sobrescrevem os conflitos do KWin.
