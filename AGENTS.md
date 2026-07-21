# AGENTS.md

## Objective

Maintain this repository as an Obsidian Vault that acts as a reusable AI brain for engineering, software architecture, backend/API, Linux, NixOS, DevOps, security, algorithms, product thinking, prompts, Skills, playbooks and technical study.

Make the smallest correct change that improves the vault without creating duplication or noise.

Optimize for:

1. correctness
2. clarity
3. reuse
4. safety
5. maintainability
6. linkability
7. low token cost
8. human learning

This repository is not a random note dump. It is an operational knowledge system.

---

## Repository role

This vault stores:

- technical notes
- MOCs / maps of content
- reusable prompts
- reusable Skills
- project templates
- playbooks
- ADRs
- checklists
- study plans
- troubleshooting notes
- engineering decisions
- AI workflow documentation

The vault must help a human engineer stay above the AI, not dependent on it.

---

## Kryonix multi-repository documentation policy

When work touches the Kryonix ecosystem repositories, keep documentation in
the vault unless the target repository already has an explicit local docs
surface for that exact kind of file.

Rules:

- Do not create loose Markdown files in the root of `kryonix` or
  `kryxd`.
- Store reusable documentation, ADRs, operational logs, runbooks, design notes,
  prompts and decisions in `kryonix-vault`.
- Use the real vault layout from this file; do not invent numbered folders.
- Update the vault only when there is a relevant result, decision, merge,
  validation outcome or reusable workflow.
- Project-specific implementation prompts belong in `04-Recursos/prompts/`,
  `04-Recursos/playbooks/` or the relevant `03-Projetos/` note, not inside
  this `AGENTS.md`.
- If a UI or docs change conflicts with the real backend/runtime behavior,
  documentation and UI copy must reflect the real behavior.
- Never document `PARTIAL`, `UNKNOWN` or `BROKEN` behavior as complete.

---

## First steps before editing

Before creating or changing a file:

1. inspect the existing folder structure;
2. identify the correct area;
3. search for an existing related note;
4. prefer updating an existing note over creating a duplicate;
5. add useful Obsidian links;
6. preserve existing links and headings;
7. avoid broad reorganization unless explicitly requested.

---

## Obsidian link rules

Use internal links aggressively but intentionally.

Preferred format:

```md
[[VAULT_INDEX]]
[[01-MOCs/Mapa - Engenharia de Software]]
[[04-Recursos/playbooks/Playbook - Criar Issue para Codex]]
```

Rules:

- Every important note should link to at least one MOC.
- Every MOC should link to its main notes.
- Do not create dead links intentionally.
- If a link points to a new concept, create the target note or add it to backlog.
- Prefer stable note names over clever names.
- Use Portuguese note names unless the technical term is better in English.

---

## Folder ownership

Use this structure (real filesystem — verified):

```txt
00-Inbox/                 raw capture, temporary notes
01-MOCs/                  maps of content and navigation hubs
02-Areas/                 long-lived knowledge areas
03-Projetos/              active project notes (with deadline)
04-Archive/               inactive / legacy
04-Recursos/              reusable assets
  ├── templates/            YAML + XML Claude + TOON templates
  ├── skills/               reusable AI/Codex skills
  ├── playbooks/            operational procedures
  │   └── runbooks/           command-bound procedures
  └── prompts/              reusable prompts
08-Referencias/           external references and source summaries
09-Logs/                  reviews, decisions, evidence, session logs
  ├── sessions/              per-session logs
  └── evidence/              validation artefacts
```

NOTE: 04-Archive and 04-Recursos share the 04- prefix by design; this is intentional.
Do NOT create 05-Skills/, 06-Playbooks/, or 07-Prompts/ — they do not exist.

Do not put everything in the root.

---

## Note quality standard

A good note must be:

- short enough to reuse;
- specific enough to be useful;
- linked to related notes;
- explicit about practical use;
- clear about risks and trade-offs;
- free from fake certainty.

Preferred note template:

```md
# Title

## Objetivo

## Resumo

## Quando usar

## Procedimento / Conteúdo

## Checklist

## Riscos

## Links relacionados

## Próxima ação

#tags
```

---

## MOC rules

MOCs are navigation pages, not long articles.

A MOC should contain:

- purpose of the area;
- key notes;
- active projects;
- related prompts;
- related Skills;
- related playbooks;
- study path;
- open questions.

Keep MOCs readable and curated.

---

## Prompt rules

Prompts must be reusable and operational.

Each prompt must include:

- role;
- objective;
- context required;
- input expected;
- output expected;
- constraints;
- validation checklist;
- failure cases;
- example usage.

Do not create vague prompts like "make this better".

---

## Skill rules

Skills must be concrete workflows.

Each Skill must include:

- name;
- purpose;
- when to use;
- when not to use;
- input expected;
- output expected;
- procedure;
- checklist;
- risks;
- token-saving mechanism;
- base prompt.

Skills should reduce repeated long prompts.

---

## Engineering knowledge rules

When adding engineering content, prefer practical production knowledge.

Always consider:

- security;
- tests;
- maintainability;
- observability;
- rollback;
- performance;
- cost;
- human learning;
- operational simplicity.

Avoid:

- hype;
- cargo cult architecture;
- unnecessary microservices;
- premature abstractions;
- blind dependency recommendations;
- security theater;
- AI-generated claims without validation.

---

## Software engineering standards

For code-related notes, prompts or playbooks, prefer:

- smallest correct change;
- explicit types;
- narrow interfaces;
- clear errors;
- validation at boundaries;
- automated tests;
- OpenAPI or clear contracts for APIs;
- structured logs;
- safe defaults;
- explicit rollback strategy.

Accept larger functions when they preserve transactional integrity, ordering, security-sensitive sequences or algorithmic clarity.

Do not split code only to satisfy a line-count rule.

---

## Backend/API standards

For backend/API content, include where relevant:

- HTTP semantics;
- REST/RPC/GraphQL trade-offs;
- authentication;
- authorization;
- object-level authorization;
- input validation;
- rate limiting;
- idempotency;
- database transactions;
- migrations;
- cache;
- queues/jobs;
- error model;
- OpenAPI;
- observability;
- security testing.

---

## NixOS / Linux / infrastructure standards

For NixOS, Linux and infra notes, include where relevant:

- reproducibility;
- flakes;
- modules;
- devShells;
- overlays;
- secrets;
- systemd units;
- service hardening;
- logs;
- rollback;
- host/profile separation;
- declarative configuration;
- operational failure modes.

Never suggest storing secrets in the Nix store, logs or repo.

---

## Security rules

Never create notes or prompts that encourage unsafe automation.

Do not suggest:

- committing secrets;
- logging credentials;
- broad production permissions for agents;
- destructive commands without backup and rollback;
- disabling security controls without explicit trade-off;
- unaudited remote scripts;
- AI-only security decisions.

Security content should include misuse cases and validation steps.

---

## AI usage rules

This vault should make AI cheaper and safer by:

- storing fixed context in notes;
- storing workflows as Skills;
- storing decisions as ADRs;
- storing procedures as playbooks;
- storing prompts as reusable templates;
- using short project summaries;
- creating small Codex issues;
- separating planning, execution and review.

Do not produce bloated notes that increase token cost.

---

## Source and uncertainty rules

When adding factual claims:

- prefer official docs, books or trusted references;
- include source link in [[08-Referencias/Fontes Oficiais]] when useful;
- distinguish fact, good practice, opinion and hypothesis;
- mark uncertainty explicitly;
- do not fabricate citations.

---

## Empty workspace bootstrap behavior

If the workspace is empty or nearly empty, create the initial vault structure:

```txt
README.md
VAULT_INDEX.md
PROMPT_MASTER.md
AGENTS.md
CLAUDE.md
00-Inbox/Inbox.md
01-MOCs/*.md
02-Areas/*/*.md
03-Projetos/_Template - Projeto.md
04-Recursos/templates/*.md
04-Recursos/skills/*/SKILL.md
04-Recursos/playbooks/*.md
04-Recursos/prompts/*.md
08-Referencias/*.md
09-Logs/sessions/.md
09-Logs/evidence/README.md
scripts/check_obsidian_links.py
justfile
.github/workflows/vault-check.yml
```

Use clear, minimal initial content and links.

---

## AI agent prompt

System prompt canonico para IAs que operam este vault:
[[04-Recursos/prompts/PROMPT_AGENT_KRYONIX_VAULT]].

Antes de criar ou atualizar notas no Vault, agentes devem seguir [[04-Recursos/skills/aura/OBSIDIAN_VAULT_PROTOCOL]].

Carrega regras MOC-first, TOON, frontmatter, links e tratamento de falsos positivos do
`scripts/check_obsidian_links.py`.

## Completion checklist

Before finishing any change:

- [ ] correct folder used
- [ ] no unnecessary duplication
- [ ] note has useful title
- [ ] note links to related MOC
- [ ] important MOC updated
- [ ] prompt/Skill/playbook has clear input and output
- [ ] security risks considered
- [ ] no secrets added
- [ ] claims do not pretend certainty without evidence
- [ ] Markdown is readable
- [ ] Obsidian links are valid where practical
