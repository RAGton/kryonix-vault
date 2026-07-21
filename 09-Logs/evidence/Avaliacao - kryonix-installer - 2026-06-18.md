# Avaliação de Qualidade — kryxd

> **Repositório:** `github:RAGton/kryxd`
> **Data:** 2026-06-18
> **Avaliador:** Agente AI (Claude Opus 4.6)
> **Commit HEAD:** `53efed6` (main)

---

## Objetivo

Avaliar sistematicamente a qualidade do repositório `kryxd` em segurança, arquitetura, testes, CI, manutenibilidade, documentação e operacionalidade. Produzir um plano de melhoria priorizado.

---

## Resumo Executivo

O repositório é um backend Axum (Rust) + frontend Vite/React que orquestra a instalação do KryonixOS. Tem **~5.700 linhas Rust** + UI React, com CI GitHub Actions, flake Nix e schema JSON. O nível geral é **BOM com áreas de risco identificadas**, especialmente em:

- **main.rs monolítico** (1.273 linhas) — God file que mistura tipos, rotas, validação e handlers
- **Segurança de input** parcialmente coberta — hostname/user validados, mas interface/disk path confiados do front
- **Testes unitários sólidos** mas sem testes de integração do pipeline real
- **Schema JSON desatualizado** — não reflete campos novos (network, target_remote_access, authorized_keys)

**Nota global: 7.2/10**

---

## 1. Segurança

### Pontos Fortes ✅

| Aspecto | Evidência |
|---------|-----------|
| **Token OAuth só em memória** | `auth.rs:17` — `access_token` nunca persiste em disco |
| **device_code nunca exposto à UI** | `auth.rs:12` — só `user_code` e `verification_uri` saem |
| **Sanitização de stderr** | `auth.rs:401` — token removido de mensagens de erro |
| **Hostname RFC-1123** | `main.rs:550-561` — rejeita shell metas, path traversal |
| **Username validation** | `main.rs:667-675` — só alfanumérico + `_` + `-` |
| **Denylist de segredos no copy** | `target_tree.rs:60-84` — `.env`, `.pem`, `.key`, `secrets` |
| **Proteção ISO boot disk** | `disk.rs:322-369` — impede formatar o USB de boot |
| **Safety checks em camadas** | `safety.rs` — dry-run + safety gate antes de executar |
| **Senha nunca serializada** | `main.rs:1068-1081` — teste documenta intenção |
| **WiFi password sanitização** | `network.rs:341,377-385` — nunca loga, sanitiza output |
| **CorsLayer::permissive** | Aceitável para live ISO efêmera, mas documentado |

### Riscos Identificados ⚠️

| # | Risco | Severidade | Local |
|---|-------|-----------|-------|
| S1 | `interface` name do front-end não é sanitizado — potencial injection em args do `nmcli` | **MÉDIA** | `network.rs:362,420` |
| S2 | `clone_url` aceita qualquer URL sem validação de domínio ou scheme | **MÉDIA** | `auth.rs:381` |
| S3 | `disk.target` passa pelo `is_valid_disk_path` (regex), mas `device` no `get_partitions` usa filtro por char — inconsistência | **BAIXA** | `disk.rs:206,412-421` |
| S4 | Logs de disko/nixos-install vão para `/tmp/` sem controle de permissão | **BAIXA** | `nixos.rs:12` |
| S5 | `GITHUB_CLIENT_ID` lido de env sem validação de formato | **BAIXA** | `auth.rs:92` |
| S6 | `profiles.rs` escreve em `/etc/kryonixos/hosts/*/default.nix` sem validação do `host` input | **MÉDIA** | `profiles.rs:22` |

---

## 2. Arquitetura

### Pontos Fortes ✅

- **Separação clara backend/frontend** — diretórios independentes com builds isolados
- **Executor pipeline** bem decomposto: `partition → kryonixos → preflight → nixos-install → verify`
- **Target Flake v2** — design autocontido (`path:./engine`) elimina `--impure`
- **Compat shim** em `kryonixos.rs` — migração gradual sem quebrar call sites
- **Broadcast channels para SSE** — padrão idiomático para streaming de progresso
- **Nix derivations limpas** — `package.nix` e `ui.nix` separadas, `lib.cleanSource`

### Problemas Identificados ⚠️

| # | Problema | Impacto |
|---|---------|---------|
| A1 | **`main.rs` com 1.273 linhas** — tipos, rotas, validação, handlers tudo junto | Manutenibilidade, code review |
| A2 | **Duplicação de lógica** `install_targets()` aparece em `main.rs:687` e `safety.rs:54` com nomes diferentes (`manual_targets`) | Bug risk em divergência |
| A3 | **`validate_plan` e `run_safety_checks` fazem checks sobrepostos** — disco, hostname | Confusão de responsabilidade |
| A4 | **`target_tree.rs` com 1.103 linhas** — geração Nix, preflight, copy engine, tudo junto | Segundo god file |
| A5 | **Erro types inconsistentes** — `String` como error everywhere, sem enum ou `thiserror` | Debug mais difícil |
| A6 | **`Permissions::from_mode_compat` trait** desnecessário — `#[cfg(unix)]` já é suficiente num projeto Linux-only | Over-engineering pontual |

---

## 3. Testes

### Cobertura Atual

| Módulo | Testes | Tipo | Qualidade |
|--------|--------|------|-----------|
| `main.rs` | 14 | Unit (validação) | ✅ Excelente — shell injection, path traversal, RAID |
| `disk.rs` | 6 | Unit (eligibility, deserialization) | ✅ Bom |
| `auth.rs` | 2 | Unit (URL injection) | ⚠️ Mínimo |
| `network.rs` | 9 | Unit (parsing, validation) | ✅ Bom |
| `partition.rs` | 5 | Unit (config generation) | ✅ Bom — cobre manual ESP EF00 |
| `safety.rs` | 3 | Unit (block device, space, uniqueness) | ✅ Bom |
| `verify.rs` | 2 | Unit (partition targets) | ⚠️ Mínimo |
| `kryonixos.rs` | 1 | Integration-like (missing engine) | ✅ Bom |
| `target_tree.rs` | ~15 | Unit (Nix generation, SSH keys, features) | ✅ Excelente |

### Lacunas

| # | Lacuna | Prioridade |
|---|--------|-----------|
| T1 | **Zero testes de integração HTTP** — nenhum teste usa `axum::test` ou reqwest contra o Router | ALTA |
| T2 | **Sem testes para `detection.rs`** | MÉDIA |
| T3 | **Sem testes para `profiles.rs`** (patch_imports) | MÉDIA |
| T4 | **Sem fuzzing** para inputs do frontend (hostname, disk path, network config) | MÉDIA |
| T5 | **Sem snapshot testing** para os módulos `.generated.nix` | BAIXA |

**Estimativa de cobertura real: ~55-60%** (lógica pura bem testada, handlers e I/O não testados)

---

## 4. CI/CD

### Pipeline Atual (`.github/workflows/ci.yml`)

```
3 jobs paralelos:
├── nix-flake: flake show → flake check → build default (com Cachix)
├── cargo: fmt → clippy → test
└── ui: npm ci → npm test → npm run build
```

### Avaliação

| Aspecto | Status | Nota |
|---------|--------|------|
| Lint Rust (clippy -D warnings) | ✅ | Rigoroso |
| Formatação Rust | ✅ | cargo fmt --check |
| Testes Rust | ✅ | cargo test --locked |
| UI testes | ✅ | npm test |
| Build completo via Nix | ✅ | Garante reprodutibilidade |
| Cachix integrado | ✅ | Evita rebuild |
| Security audit (cargo audit) | ❌ | **Ausente** |
| Dependency update automation | ❌ | **Sem Dependabot/Renovate** |
| Release tagging | ❌ | **Ausente** |
| SAST / secret scanning | ❌ | **Ausente** |

---

## 5. Documentação

| Aspecto | Status | Avaliação |
|---------|--------|-----------|
| README.md | ✅ | Bom — layout, build, consumo |
| JSON Schema | ⚠️ | **Desatualizado** — falta network, target_remote_access, authorized_keys, uid, email |
| Inline comments (Rust) | ✅ | Excelentes — em português, explicam "porquê" |
| API documentation (OpenAPI) | ❌ | **Ausente** — 30+ endpoints sem spec |
| CHANGELOG | ❌ | **Ausente** |
| ADR (decisões arquiteturais) | ⚠️ | Parcial — `pr-body.md` documenta uma decisão |
| Contributing guide | ❌ | **Ausente** |

---

## 6. Qualidade de Código

| Métrica | Valor | Avaliação |
|---------|-------|-----------|
| Linhas Rust | 5.702 | Adequado para o escopo |
| Maior arquivo | `main.rs` (1.273 LOC) | ⚠️ Precisa split |
| 2º maior | `target_tree.rs` (1.103 LOC) | ⚠️ Precisa split |
| `#[allow(clippy::...)]` | 1 (`disk.rs:1`) | ✅ Mínimo |
| Dependências | 15 (Cargo.toml) | ✅ Enxuto |
| Edition Rust | 2024 | ✅ Atualizado |
| nixpkgs pin | nixos-26.05 | ✅ Atualizado |
| Dead code / legacy routes | 4 rotas GONE | ⚠️ Limpar |

---

## 7. Manutenibilidade

### Positivo

- Código idiomático Rust — bom uso de `Result`, `Option`, pattern matching
- Comentários explicam decisões não-óbvias (NAR hash mismatch, flake.lock)
- Nix packaging limpo e reproduzível
- `.gitignore` completo

### Negativo

- Sem `tracing` em uso (dependência existe no Cargo.toml mas não é usada)
- `println!` em vez de structured logging (`profiles.rs:42,46,56`)
- Error types são `String` — sem contexto estruturado para debugging
- Sem rate limiting nos endpoints
- `pr-body.md` no root — deveria estar em `.github/` ou no vault

---

## Scorecard Final

| Categoria | Peso | Nota (0-10) | Ponderado |
|-----------|------|-------------|-----------|
| Segurança | 25% | 7.5 | 1.875 |
| Arquitetura | 20% | 6.5 | 1.300 |
| Testes | 20% | 7.0 | 1.400 |
| CI/CD | 10% | 7.5 | 0.750 |
| Documentação | 10% | 5.5 | 0.550 |
| Qualidade de Código | 10% | 7.5 | 0.750 |
| Manutenibilidade | 5% | 6.5 | 0.325 |
| **TOTAL** | **100%** | | **6.95** |

**Classificação: BOM (precisa melhorias focadas)**

---

## Plano de Melhoria

### Fase 1 — Segurança & Correções Críticas (1-2 semanas)

- [ ] **S1:** Sanitizar `interface` name em `network.rs` — whitelist `[a-zA-Z0-9._-]`
- [ ] **S6:** Sanitizar `host` em `profiles.rs` — mesma whitelist de hostname
- [ ] **S2:** Validar `clone_url` — aceitar apenas `https://github.com/` como prefixo
- [ ] **A2:** Unificar `install_targets` / `manual_targets` — extrair para função única em módulo compartilhado
- [ ] Substituir `println!` por `tracing::info!` / `tracing::warn!` em todo o codebase

### Fase 2 — Arquitetura & Split (2-4 semanas)

- [ ] **A1:** Extrair de `main.rs`:
  - `src/types.rs` — InstallPlan, PlanDisk, PlanUser, etc.
  - `src/routes.rs` — Router builder e handler wiring
  - `src/validation.rs` — validate_plan, is_valid_hostname, validate_install_target
  - `src/handlers/` — um arquivo por domínio (plan, install, debug, disk, reboot)
- [ ] **A4:** Extrair de `target_tree.rs`:
  - `src/executor/nix_gen.rs` — geração dos módulos `.generated.nix`
  - `src/executor/preflight.rs` — PreflightReport e scans
  - `src/executor/engine_copy.rs` — copy_engine, denylist, walkdir
- [ ] **A5:** Introduzir `thiserror` para error enums tipados
- [ ] Remover rotas GONE (disk_apply, install_finalize, partition, reboot) — substituir por 404 limpo
- [ ] Mover `pr-body.md` para `.github/` ou deletar

### Fase 3 — Testes & Qualidade (2-3 semanas)

- [ ] **T1:** Adicionar testes de integração HTTP com `axum::test::TestClient`:
  - `GET /health` retorna 200 + status ok
  - `POST /plan` com payload mínimo retorna InstallPlan
  - `POST /dry-run` com disco inválido retorna 422
  - `POST /install` com mode=dry-run nunca toca disco
- [ ] **T2:** Testes para `detection.rs` — mock filesystem
- [ ] **T3:** Testes para `profiles.rs::patch_imports` — insert, idempotência, malformed
- [ ] **T5:** Snapshot tests para cada `.generated.nix` renderizado
- [ ] Adicionar `cargo-audit` ao CI
- [ ] Adicionar Dependabot/Renovate para Rust + npm

### Fase 4 — Documentação & Operacionalidade (1-2 semanas)

- [ ] Atualizar `schemas/install-plan.schema.json` para v2:
  - Adicionar `network`, `target_remote_access`, `user.uid`, `user.email`, `user.authorized_keys`
- [ ] Gerar OpenAPI spec com `utoipa` ou documentar endpoints manualmente
- [ ] Criar CHANGELOG.md (pode ser automático com `git-cliff`)
- [ ] Criar ADR no vault: "Decisão — Target Flake v2 (autocontido)"
- [ ] Documentar variáveis de ambiente no README:
  - `KRYONIX_INSTALLER_UI_DIR`
  - `KRYONIX_INSTALLER_BIND`
  - `KRYONIX_ENGINE_SOURCE`
  - `KRYONIX_HARDWARE_PROBE`
  - `GITHUB_CLIENT_ID`

### Fase 5 — Hardening Futuro (backlog)

- [ ] Rate limiting com `tower::limit` nos endpoints públicos
- [ ] Structured logging com `tracing-subscriber` + JSON
- [ ] Métricas Prometheus via `metrics` crate
- [ ] Timeout configurável para `nixos-install` (hoje roda sem limite)
- [ ] Suporte a cancelamento de instalação via token
- [ ] IPv6 validation nos helpers de rede

---

## Riscos

- **Split do main.rs** pode quebrar imports — fazer em PR atômico com testes verdes
- **Atualização do schema** pode impactar UI — coordenar com frontend
- **cargo-audit** pode revelar CVEs em dependências — avaliar antes de ativar o CI gate

---

## Links relacionados

- [[03-Projetos/KryonixOS Installer]]
- [[01-MOCs/Mapa - Engenharia de Software]]
- [[02-Areas/NixOS/Flakes]]

## Próxima ação

Executar **Fase 1** (segurança + sanitização) como primeiro PR.

#kryonix #installer #review #qualidade #segurança
