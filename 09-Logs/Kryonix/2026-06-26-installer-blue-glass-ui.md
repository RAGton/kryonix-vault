# Kryonix Installer Blue Glass UI

Data: 2026-06-26
Agente: Codex
Repos afetados:

- repos/kryonix-installer
- repos/kryonix-vault

## Objetivo

Auditar a base visual do installer web e aplicar uma primeira revisao de UI
mais minimalista, arredondada, azul e com vidro fosco, sem alterar contrato de
rede, discos, schema, backend ou ISO.

## Contexto consultado

- `AGENTS.md` do workspace
- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix-vault/VAULT_INDEX.md`
- `repos/kryonix-vault/02-Areas/Kryonix/installer/UI Flow.md`
- `repos/kryonix-vault/03-Projetos/Kryonix Installer.md`
- `repos/kryonix-vault/04-Recursos/prompts/PROMPT_AGENT_SITE_MODERNO.md`
- `repos/kryonix-vault/04-Recursos/skills/vibe-coding/ui-reference-extraction/SKILL.md`
- `repos/kryonix-installer/ui/src/App.jsx`
- `repos/kryonix-installer/ui/src/components/Layout.jsx`
- `repos/kryonix-installer/ui/src/components/Background3D.css`
- `repos/kryonix-installer/ui/src/index.css`
- `repos/kryonix-installer/ui/src/pages/Welcome.jsx`

## Mudancas realizadas

- Substituida a pele HUD escura por tokens `Blue Glass`: superficies
  translucidas, blur, bordas claras, botoes em pill e contraste mais alto.
- Fundo animado trocado de triangulos 3D ruidosos para linhas e faixas de luz
  azuis mais discretas, com suporte a `prefers-reduced-motion`.
- Componentes globais (`section-panel`, `glass-panel`, botoes, inputs, cards,
  footer e modal) foram alinhados ao novo visual.
- Corrigidas variaveis CSS que eram usadas sem definicao (`--border1`,
  `--bg-card`, `--primary-low`).
- Corrigida propriedade CSS invalida `flex-col: column` para
  `flex-direction: column`.
- Tela Welcome deixou de falar de refatoracao interna e passou a comunicar o
  fluxo real de instalacao, revisao final e operacao local.
- SVG da Welcome ajustado para atributos camelCase do React.

## Commits e branches

- Branch em `repos/kryonix-installer`: `fix/installer-ui-network-ux`
- Commits nao realizados nesta execucao.

## Validacoes executadas

- `cd repos/kryonix-installer/ui && npm test` — PASS, 65/65 testes.
- `cd repos/kryonix-installer/ui && npm run build` — PASS.
- `cd repos/kryonix-installer && git diff --check` — PASS.
- `cd repos/kryonix-installer/ui && npm run dev -- --host 127.0.0.1 --port 5173` — PASS, Vite subiu.
- `curl -sS -I http://127.0.0.1:5173/` — PASS, HTTP 200.
- `agent-browser ...` — BROKEN no ambiente local: comando nao existe no PATH.
- Browser local/Playwright — UNKNOWN: `playwright` nao esta instalado e nao foi
  encontrado Chromium/Firefox/Chrome no PATH.

## Evidencias

- O build gerou `dist/index.html`, CSS e JS versionados pelo Vite sem erro.
- A resposta HTTP do dev server retornou `Content-Type: text/html` e body com
  `#root` e `/src/main.jsx`.
- A mudanca ficou restrita a UI/CSS/Welcome, sem alteracao em backend,
  storage, particionamento, rede aplicada ou schema.

## Pendencias

- Validar visualmente em Chromium/kiosk real da ISO ou em ambiente com
  `agent-browser`/browser disponivel.
- Navegar pelo wizard inteiro em viewport desktop e mobile para detectar
  overflow, texto cortado ou contraste ruim em paginas internas densas.
- Executar validacao E2E da ISO/VM antes de declarar o installer visualmente
  pronto.

## Proximo passo recomendado

Rodar a ISO em VM descartavel, abrir o web-kiosk real e capturar screenshots das
etapas Welcome, Network, Disks, Summary e Install para fechar a revisao visual.
