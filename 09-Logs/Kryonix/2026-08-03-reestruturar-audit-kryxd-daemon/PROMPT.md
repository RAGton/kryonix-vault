---
title: Prompt — Reestruturar audit kryxd-daemon
date: 2026-08-03
tags: [kryonix, kryxd, audit, prompt, operational]
status: archived
agent_source: Aura v1.1
target_agent: outro chat (modelo M3)
executed: false
result: pending
---

# Prompt operacional — Reestruturar audit kryxd-daemon

> Prompt enviado para o outro chat em 2026-08-03 para reestruturar a pasta de audit do kryxd-daemon conforme decisão tomada com Gabriel.
> **Status:** enviado manualmente (não houve execução automatizada).
> **Resultado:** pendente — Gabriel colou manualmente no outro chat.

# Reestruturação cosmética do vault: audit kryxd-daemon

## Contexto

O Vault em `~/Proyectos/Rocha-Vault/02-Areas/Kryonix/canonical/audits/` tem hoje:

```
audits/
├── _MOC_kryxd-audits.md
└── 2026-08-03-kryxd-arquitetura/
    └── 11-evidence-pack.md
```

A Aura revisou isso e identificou problemas:

1. A MOC mistura índice de auditorias com roadmap de KCRs pendentes (vai virar lixeira)
2. O nome da pasta `-kryxd-arquitetura` é ambíguo (arquitetura de quê? daemon, UI, CLI?)
3. O arquivo `11-evidence-pack.md` mistura veredito executivo + análise + evidência bruta (não separa decisão de evidência)
4. Faltam frontmatter YAML em todos os arquivos (convenção do vault)
5. Não há arquivo de errata (auditorias envelhecem mal sem isso)
6. Não há roadmap espelhando o Kanban Hermes
7. Falta baseline de compilação (Gap real — mas NÃO é escopo desta tarefa)

A estrutura-alvo foi validada:

```
audits/
├── _MOC_kryxd-daemon-audits.md              ← renomeia + atualiza referências internas
├── _roadmap_kryxd-daemon-debt.md            ← NOVO (espelho do Kanban Hermes, status blocked)
└── 2026-08-03-kryxd-daemon-structural-audit/   ← renomeia pasta
    ├── 00-summary.md                        ← NOVO (veredito executivo + TL;DR)
    ├── 10-structural-audit.md               ← split do 11 atual (achados + análises, SEM output bruto)
    ├── 11-evidence-pack.md                  ← só comandos + outputs brutos capturados
    ├── 20-build-baseline.md                 ← NOVO (stub: ainda não existe, será populado depois)
    └── 90-errata.md                         ← NOVO (stub vazio)
```

## Escopo (RÍGIDO)

**Você PODE:**
- Renomear arquivos e pastas dentro de `~/Proyectos/Rocha-Vault/02-Areas/Kryonix/canonical/audits/`
- Criar os arquivos novos listados acima
- Adicionar frontmatter YAML em todos os arquivos
- Atualizar wikilinks internos (`[[...]]`) que mudaram de nome
- Usar `git mv` para preservar histórico

**Você NÃO PODE:**
- ❌ Commitar nada (`git commit` está PROIBIDO)
- ❌ Dar push
- ❌ Usar `git add .` ou `git add -A`
- ❌ Mexer em qualquer arquivo fora de `audits/`
- ❌ Criar arquivos fora da lista de 6 acima
- ❌ Rodar `cargo build`, `cargo test`, `nix build` ou qualquer coisa de compilação
- ❌ Mexer no `kryonix-dev` meta-repo ou no pointer do submodule
- ❌ Inventar conteúdo que não veio do `11-evidence-pack.md` atual — o split é só reorganização

## Ordem de execução (SIGA EXATAMENTE)

1. **Validar estado inicial**
   ```bash
   cd ~/Proyectos/Rocha-Vault
   git status --short
   git log -1 --oneline
   ls -la 02-Areas/Kryonix/canonical/audits/
   ```

2. **Renomear a MOC** (preservando histórico via `git mv`)
   ```bash
   cd ~/Proyectos/Rocha-Vault
   git mv 02-Areas/Kryonix/canonical/audits/_MOC_kryxd-audits.md \
          02-Areas/Kryonix/canonical/audits/_MOC_kryxd-daemon-audits.md
   ```

3. **Renomear a pasta** (preservando histórico)
   ```bash
   cd ~/Proyectos/Rocha-Vault
   git mv 02-Areas/Kryonix/canonical/audits/2026-08-03-kryxd-arquitetura \
          02-Areas/Kryonix/canonical/audits/2026-08-03-kryxd-daemon-structural-audit
   ```

4. **Ler o conteúdo atual** do `11-evidence-pack.md` dentro da pasta renomeada — você vai precisar dele para o split

5. **Criar `00-summary.md`** — extrair do `11-evidence-pack.md` atual:
   - TL;DR (tabela de achados com severidade)
   - Veredito geral
   - Honestidade intelectual
   - NÃO incluir outputs brutos de comandos (isso vai pro `11-evidence-pack.md`)

6. **Criar `10-structural-audit.md`** — extrair do `11-evidence-pack.md` atual:
   - Inventário (1.1, 1.2)
   - Achados detalhados com análise (seção 2 inteira)
   - Princípios violados (Clean Code / GoF)
   - NÃO incluir outputs brutos de comandos
   - NÃO incluir TL;DR (já foi pro `00-summary.md`)

7. **Truncar o `11-evidence-pack.md` original** — manter SÓ:
   - Cabeçalho (data, escopo, repo, metodologia, referências)
   - Seção "0. TL;DR" resumida em 3-5 linhas (ou remover — o veredito tá no `00-summary.md`)
   - **TODOS** os blocos de código com `Evidência:` (outputs brutos de comandos)
   - Remover: inventário, achados detalhados, princípios violados (foram pro `10`)

8. **Criar `20-build-baseline.md`** (stub):
   ```markdown
   ---
   title: Build baseline kryxd-daemon (Gate A.1)
   date: 2026-08-03
   tags: [kryonix, kryxd, audit, baseline, pending]
   status: pending
   ---

   # Build baseline kryxd-daemon (Gate A.1)

   > Stub. Será populado quando Gabriel rodar `cargo build` + `cargo test` no `repos/kryxd`.
   > Bloqueia KCR-TARGETTREE-1 e KCR-REFACTOR-1 (ver `_roadmap_kryxd-daemon-debt.md`).

   ## Comandos a executar

   ```bash
   cd ~/Proyectos/kryonix-dev/repos/kryxd
   cargo fmt --check
   cargo build --workspace
   cargo test --workspace
   ```

   ## Critério de "verde"

   - `cargo build` sem erros
   - `cargo test` 100% passing
   - Sem warnings novos

   ## Resultado

   _A ser preenchido._
   ```

9. **Criar `90-errata.md`** (stub vazio):
   ```markdown
   ---
   title: Errata — audit estrutural kryxd-daemon 2026-08-03
   date: 2026-08-03
   tags: [kryonix, kryxd, audit, errata]
   status: empty
   ---

   # Errata

   > Documenta correções, revisões e superssets deste audit.
   > Sem errata até o momento.

   | Data | Achado original | Correção | Referência |
   |------|-----------------|----------|------------|
   | _vazio_ | _vazio_ | _vazio_ | _vazio_ |
   ```

10. **Criar `_roadmap_kryxd-daemon-debt.md`** — espelho do Kanban Hermes (use os IDs reais que você pode obter via `hermes kanban list`):
    ```markdown
    ---
    title: Roadmap kryxd-daemon debt
    date: 2026-08-03
    tags: [kryonix, kryxd, roadmap, debt, blocked]
    status: in-progress
    ---

    # Roadmap kryxd-daemon debt

    > Espelho do Kanban Hermes. SSOT é o Kanban.
    > Última sincronização: 2026-08-03

    | KCR | Status | Kanban ID | Esforço | Bloqueado por |
    |-----|--------|-----------|---------|---------------|
    | KCR-ROUTER-1 | blocked | _preencher_ | 1-2h | 20-build-baseline.md |
    | KCR-TRANSLATOR-1 | blocked | _preencher_ | 30-60min | 20-build-baseline.md |
    | KCR-V1-DEPRECATE | blocked | _preencher_ | 2h | 20-build-baseline.md |
    | KCR-PARTITIONER-1 | blocked | _preencher_ | 2-3h | 20-build-baseline.md |
    | KCR-TARGETTREE-1 | blocked | _preencher_ | 1 dia | 20-build-baseline.md + KCR-PARTITIONER-1 |
    | KCR-REFACTOR-1 | blocked | _preencher_ | 2-3 dias | 20-build-baseline.md + KCR-TARGETTREE-1 |
    ```

    **Ação:** rode `hermes kanban list | grep -i "kryxd"` para obter os IDs reais. Se não houver cartões Kanban ainda, deixe `_a criar_` no campo Kanban ID.

11. **Adicionar frontmatter YAML em TODOS os arquivos `.md`** que ainda não têm (a MOC renomeada e o `11-evidence-pack.md` que ficou após o split). Template mínimo:

    ```yaml
    ---
    title: <nome legível>
    date: 2026-08-03
    tags: [kryonix, kryxd, audit, structural]
    status: completed | pending | blocked | empty
    ---
    ```

    Para cada arquivo, adapte:
    - `_MOC_kryxd-daemon-audits.md` → status `index`
    - `00-summary.md` → status `completed`
    - `10-structural-audit.md` → status `completed`
    - `11-evidence-pack.md` → status `completed`
    - `20-build-baseline.md` → status `pending`
    - `90-errata.md` → status `empty`
    - `_roadmap_kryxd-daemon-debt.md` → status `in-progress`

12. **Atualizar wikilinks internos** — se a MOC original referenciava `[[2026-08-03-kryxd-arquitetura/11-evidence-pack|...]]`, agora tem que apontar para a pasta/arquivo renomeados. Faça uma busca:
    ```bash
    cd ~/Proyectos/Rocha-Vault
    rg -n "2026-08-03-kryxd-arquitetura" 02-Areas/Kryonix/canonical/audits/
    rg -n "_MOC_kryxd-audits" 02-Areas/Kryonix/canonical/audits/
    ```
    Corrija cada referência.

13. **Validar estado final**:
    ```bash
    cd ~/Proyectos/Rocha-Vault
    git status --short
    ls -la 02-Areas/Kryonix/canonical/audits/
    ls -la 02-Areas/Kryonix/canonical/audits/2026-08-03-kryxd-daemon-structural-audit/
    ```

## Entregável final (responda no chat com TUDO isso)

1. **Diff conceitual** — lista dos 6 arquivos finais com 1 linha descrevendo o conteúdo de cada
2. **Lista de comandos `git mv` executados** (na ordem)
3. **Lista de arquivos criados** (com path absoluto)
4. **Wikilinks atualizados** (antes → depois)
5. **`git status --short` final** (deve mostrar arquivos renomeados como `R` e novos como `??`)
6. **Avisos** — qualquer coisa que você não conseguiu fazer ou que ficou diferente do spec

## Honestidade intelectual

- Se algum comando falhar ou algum arquivo não existir como esperado, **PARE e reporte antes de inventar workaround**
- Se o conteúdo do `11-evidence-pack.md` atual não tiver seções claras pra fazer o split, reporte isso — não invente estrutura
- Se os Kanban IDs não forem encontráveis via `hermes kanban list`, deixe `_a criar_` mesmo, não invente IDs

## O que fazer com o resultado

Você NÃO deve commitar. O usuário (Gabriel) vai revisar seu diff conceitual + `git status` final, e ele mesmo commita depois de validar.

**Boa execução.**
