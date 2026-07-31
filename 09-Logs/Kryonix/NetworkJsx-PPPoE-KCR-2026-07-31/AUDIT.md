# Auditoria Etapa 0 — PPPoE no InstallPlanV2

Investigação de 4 arquivos do backend para fundamentar o KCR.

## Arquivos inspecionados

| Arquivo | Tamanho | Achados principais |
|---|---|---|
| `crates/kryx/src/domain/config.rs` | 389 linhas | `InstallPlanV2` struct existe, sem `network`. `try_from StoragePlanWire` é o padrão de validação a espelhar. |
| `crates/kryx/src/services/translator.rs` | 248 linhas | Traduz só `node.thinkServer`, `kryonix.storage.*`, `kryonix.features.*`. **Zero `networking.*`.** |
| `src/api/v2/think.rs` | 122 linhas | Stub — não relacionado a PPPoE (cluster topology/ZFS). |
| `ui/src/generated/installPlanSchema.js` | 325 linhas | `required`: `version, isThinkServer, repository, storage, features`. **Sem `network` em properties nem $defs.** |

## Arquivos adicionais confirmados (1 grep)

- `schemas/install-plan.schema.json` — fonte canônica (não-editável direto, regenera via `scripts/generate-ui-contracts.mjs`).
- `src/api/install.rs:317` — `pub async fn put_secrets` (handler `/api/v2/secrets` já consome `InstallSecretsV2`).
- `src/domain/secrets.rs:14` — `pub struct InstallSecretsV2 { admin_password: SecretString, pppoe_password: Option<SecretString> }` — já aceita PPPoE.
- `ui/src/components/network/WanCard.jsx` — coleta `pppoeUser` + `pppoePassword` (estado: implementado, falta propagar pro V2).
- `ui/src/utils/installPlan.js:298-309` — `buildInstallPlanPayload` retorna só `{ version, isThinkServer, repository, storage, features }` (sem `network`).

## Mapa de fluxo da senha PPPoE (Day-0)

```
UI (WanCard.jsx)
  └─ wizard.pppoePassword
       └─ /api/v2/plan → InstallPlanV2 (versão atual: NÃO inclui network)
       └─ /api/v2/secrets → InstallSecretsV2 { pppoe_password } ✅
            └─ src/api/install.rs:317 put_secrets
                 └─ atomic_write("/etc/kryonix/secrets/pppoe-<iface>", SecretString, 0600)
                      └─ configuration.nix precisa referenciar passwordFile
                           └─ translator.rs: precisa emitir networking.pppoe.<iface>.passwordFile
```

**Quebra atual:**
1. `pppoeUser` se perde entre UI e NixOS (não vai nem no V1 do plan, nem no translator)
2. `translator.rs` não emite nenhuma diretiva de rede, mesmo com `pppoeUser` chegando

## Estruturas Rust a espelhar

- **Validação rica** (não-trivial, com `deny_unknown_fields` + `try_from`)
  - Ver `StoragePlan` em `config.rs:80-174` como referência
  - Padrão: criar `XxxWire` com `deny_unknown_fields`, `try_from` que aplica regras
- **Enums com `rename_all = "camelCase"`**
  - Ver `Topology`, `FileSystem`, `Encryption` em `config.rs:7-33`
- **Testes via `assert!(result.contains(...))`** no translator
  - Padrão já estabelecido em `translator.rs:163-173`

## Decisões pendentes (registradas no KCR)

1. `network` top-level vs embutido em `storage` — **escolhido: top-level** (consistência com V1)
2. Senha PPPoE no plan? — **escolhido: NÃO, só no secrets** (segredos fora do Nix store)
3. `pppoe_user` no plan? — **escolhido: SIM** (não é segredo, é config)
4. Modos suportados na WAN: DHCP/Static/PPPoE? — **escolhido: os 3** (paridade com UI)

## Outputs do KCR

KCR-2026-07-31-01 detalhado em `KCR.md` (irmão deste arquivo na mesma pasta).

Inclui:
- Contrato Rust proposto (`NetworkPlan`, `ManagementNetwork`, `WanNetwork`, enums)
- Diff conceitual do `translator.rs` (5 cenários de tradução Nix)
- Diff da UI (`buildNetworkPlan`)
- Schema JSON V2 proposto (`$defs.networkPlan`)
- 11 testes obrigatórios (4 Rust + 3 Rust translator + 3 JS + 1 manual E2E)
- Sequência de execução em 6 passos
- Tabela de riscos + mitigações
- 3 pendências fora do escopo