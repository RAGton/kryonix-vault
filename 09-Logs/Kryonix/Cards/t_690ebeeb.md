---
card_id: t_690ebeeb
status: ready
type: 
priority: 0
created_at: 2026-07-30T21:48:15+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T19:38:06.969463+00:00
last_kanban_state: ready
result: None
auto_generated: true
audits: []
---

# [KCR] Node Think Backend Unification — Strike 1 (Contrato e Tradutor)

**Card:** `t_690ebeeb` | **Status:** `ready`

## Descrição

## Objetivo\nTipar o contrato Node Think no backend Rust do kryxd e corrigir a emissão Nix, sem alterar frontend, particionador Disko ou executar instalação.\n\n## Contexto confirmado na auditoria\n- `crates/kryx/src/services/translator.rs` gera `kryonix.thinkServer.enable`, mas o módulo real expõe `node.thinkServer.enable`.\n- `InstallPlanV2` em `crates/kryx/src/domain/config.rs` tem `isThinkServer` e features booleanas genéricas, mas não possui `hostId`.\n- `modules/node/think/think-server.nix` exige `node.thinkServer.hostId`.\n\n## Escopo Strike 1\n1. Atualizar o contrato Rust com estrutura tipada para Node Think, preservando coerência de serde e testes existentes.\n2. Corrigir `translator.rs` para emitir `node.thinkServer.enable` e `node.thinkServer.hostId`.\n3. Atualizar apenas fixtures/testes Rust necessários para compilar.\n\n## Fora de escopo\n- frontend/UI/schema JS;\n- `src/services/partitioner.rs` e Disko;\n- `src/services/target_tree.rs`;\n- módulo NixOS;\n- commits, push, PR ou deploy sem aprovação humana posterior.\n\n## Validação\n- `cargo check` em `repos/kryxd`;\n- `cargo clippy -- -D warnings`;\n- testes unitários focados do crate;\n- mostrar `git diff` de `config.rs` e `translator.rs` e outputs reais antes de qualquer registro Git.\n\n## Critério de conclusão\nO Rust compila, os testes do tradutor comprovam a saída `node.thinkServer.enable = true;` e `node.thinkServer.hostId = ...;`, não há emissão de `kryonix.thinkServer`, e nenhum arquivo fora do Strike 1 foi alterado.

## Assignment

- **Criado por:** `gabriel`
- **Assignee:** `default`

## Workspace

`/home/rocha/Proyectos/kryonix-dev/repos/kryxd`

## External ID

`kcr-node-think-backend-strike-1`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T21:48:15+00:00` | `created` | {"assignee": "default", "status": "ready", "parents": [], "tenant": "kryonix", "workspace_kind": "dir", "workspace_path": "/home/rocha/Proyectos/kryonix-dev/repos/kryxd", "branch_name": null, "project... |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T19:38:06.969467+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._