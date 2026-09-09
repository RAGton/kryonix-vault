# Habilitação Nativa do Ollama no Inspiron

Data: 2026-09-09
Agente: Antigravity
Repos afetados:

- repos/kryonixos

## Objetivo

Instalar um gestor de LLM local eficiente que rode nativamente no notebook (host: `inspiron`). O Ollama foi o escolhido devido à maturidade, eficiência em integração nativa (Kryonix OS tem suporte em `ai.ollama`/`services.ollama`), e fallback dinâmico entre Intel iGPU, AMD Radeon 520, e CPU via `llama.cpp`.

## Contexto consultado

- `AGENTS.md` (regras do ambiente, deploy imperativo vs declarativo)
- Inspeção de hardware no notebook com `lspci` (AMD Jet PRO e Intel UHD Graphics detectados)
- `repos/kryonixos/hosts/inspiron/default.nix` modificado.

## Mudanças realizadas

- Ativação declarativa de `services.ollama.enable = true;` em `repos/kryonixos/hosts/inspiron/default.nix`.
- A interface gráfica `open-webui` não foi ativada nesta passagem, focando apenas no backend (Ollama).

## Validações executadas

- `nix flake check --keep-going --impure` (passou sem erros em todos os configs: inspiron, glacier, inspiron-nina).

## Commits e branches

(Pendente: o usuário precisará aplicar via `kryx switch` e realizar o commit no submódulo de acordo com as regras).

## Pendências

- O usuário precisa rodar `kryx switch`.

## Próximo passo recomendado

- Instalar modelos (`ollama run llama3.2`) e conectar com a engine do Hermes recém-instalada.
