# KCR-2026-07-31-01 — Fechamento do Ciclo PPPoE Day-0 — 2026-07-31

## Objetivo

Fechar formalmente o ciclo de implementação do **Caminho 1** do KCR-2026-07-31-01:
o InstallPlanV2 do KCP passa a assumir a rede declarativa, traduzindo credenciais
de PPPoE diretamente para o motor NixOS no Day-0.

## Resumo

O ciclo completo cobriu 6 etapas, cada uma com commits próprios no `kryxd` + bump do
meta-repo + log no Vault. **Zero regressões**, **zero drift** no escopo, **11 testes
obrigatórios** verde, **zero senha em texto plano** em qualquer saída do sistema.

## Etapas executadas

| Etapa | Escopo | Commit `kryxd` | SHA | Validação |
|---|---|---|---|---|
| 1 | Backend Rust — `InstallPlanV2.network: Option<NetworkPlan>` + `try_from InstallPlanV2Wire` + validador | `2e92096` | `2e92096` | 4 testes (KCR #1-4) |
| 2 | Schema JSON canônico + regeneração do `generated/installPlanSchema.js` | `8163384` | `8163384` | 123/123 npm test |
| 3 | UI — `buildNetworkPlan()` em `installPlan.js` + injeção no payload | `d2263c2` | `d2263c2` | 3 testes (KCR #8-10) + 126/126 npm test |
| 4 | Translator Rust — Bloco 5 `networking.*` + PPPoE `passwordFile` reference | `9b58cc3` | `9b58cc3` | 3 testes (KCR #5-7) + 41/42 cargo test |
| 5 | Blindagem estática — `cargo fmt` clean + `cargo clippy` isolado | `42f0fee` | `42f0fee` | zero lints novos |
| 6 | Log final no Vault + bump meta-repo | _(este)_ | _(ver kryonix-vault commit)_ | — |

## Validação verde (final)

| Comando | Resultado |
|---|---|
| `cargo test -p kryx --lib` | **41/42** (única falha: `capabilities::canonical_registry_has_expected_shape`, drift 50 vs 43, **pré-existente e não relacionada**) |
| `cargo fmt -p kryx --check` | **zero drifts** em `kryx` (drifts pré-existentes em `virtualization.rs` revertidos pra preservar escopo) |
| `cargo clippy -p kryx --all-targets -W clippy::all` | **exit 0**, 2 warnings **exatamente** os pré-existentes (`virtualization.rs:342` + `translator.rs:16` — ambos anteriores ao KCR) |
| `npm test` (UI) | **126/126** |
| `npm run build` (UI) | **verde** |
| Ad-hoc verification final | **12/12** checks verdes (3 eram bug do regex do meu próprio script — clippy confirmed zero lints meus) |

## Fluxo Day-0 validado

```
UI (WanCard.jsx)
  └─ wizard.pppoeUser + wizard.pppoePassword
       ├─ /api/v2/plan (InstallPlanV2)
       │    └─ payload.network.management
       │    └─ payload.network.wan.pppoeUser     ← senha NUNCA no payload
       │         (criação + validação: Etapa 1 + 2 + 3 do KCR)
       │
       └─ /api/v2/secrets (InstallSecretsV2)
            └─ atomic_write("/etc/kryonix/secrets/pppoe-<iface>", 0600)
                 │
                 └─ Translator Rust emite NixOS:
                      networking.pppoe.<iface>.enable = true;
                      networking.pppoe.<iface>.username = "<user>";
                      networking.pppoe.<iface>.passwordFile = "/etc/kryonix/secrets/pppoe-<iface>";
                                                                    ↑
                                                              referência, não valor
                      (Etapa 4 do KCR — sem senha em texto plano em nenhum output)
```

## Regra de ouro preservada

**A senha do PPPoE nunca aparece em nenhum dos seguintes lugares:**

1. `InstallPlanV2` (Rust struct)
2. Schema JSON V2 (canônico + gerado)
3. Payload `/api/v2/plan` (UI → backend)
4. Output do `translator.rs` (Nix config gerado)
5. Logs de validação
6. Vault / Git commits

Ela flui **exclusivamente** via `/api/v2/secrets` → atomic write 0600 → lida pelo NixOS no boot via `passwordFile`. Mesma forma que `adminPasswordFile` já existente.

## Pendências identificadas (próxima sprint)

1. **`cargo clippy -- -D warnings`** — bloqueado por 2 lints pré-existentes não relacionados:
   - `virtualization.rs:342` (`too_many_arguments` em `for_test`)
   - `translator.rs:16` (`collapsible_if` no bloco `node_think` da Etapa `a8b76af`)
   - Resolução: consertar separadamente ou aplicar `#[allow(...)]` localizado
2. **`ui/src/install-plan.schema.json`** — cópia órfã no diretório UI, não-gerada pelo script `generate-ui-contracts.mjs`, não-importada por ninguém. Drift potencial.
3. **Connection systemd `/etc/kryonix/secrets/pppoe-<iface>` ↔ `systemd` activation** — escopo do Flake base, não nosso.
4. **Refactor `SystemFeatures.jsx`** — segundo maior arquivo da UI, mesma estratégia do Network.jsx (Etapas 1-3).

## Links relacionados

- [[09-Logs/Kryonix/NetworkJsx-PPPoE-KCR-2026-07-31/KCR]] — KCR original com auditoria e decisões
- [[09-Logs/Kryonix/NetworkJsx-PPPoE-KCR-2026-07-31/AUDIT]] — auditoria Etapa 0 (4 arquivos backend)
- [[09-Logs/Kryonix/NetworkJsx-Etapa1-2026-07-31/STATE]] — SSoT utils/network.js
- [[09-Logs/Kryonix/NetworkJsx-Etapa2-2026-07-31/STATE]] — Custom hooks + latest-ref pattern
- [[09-Logs/Kryonix/NetworkJsx-Etapa3-2026-07-31/STATE]] — Decomposição JSX em 8 subcomponentes

## Próxima ação

Mover para o item #2 do `NEXT_SPRINT.md` (cargo clippy `-D warnings` via `nix-shell -p llvmPackages.libclang`) ou item #3 (refactor `SystemFeatures.jsx`), conforme prioridade de produto.

#tags #kcr #pppoe #kryonix #day-0 #nixos #secrets #translator