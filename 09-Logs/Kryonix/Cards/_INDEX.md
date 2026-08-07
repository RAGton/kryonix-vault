---
generated_at: 2026-08-07T13:48:22.052292+00:00
total_cards: 100
auto_generated: true
---

# Kanban Index — kryonix

Total: **100 cards** | Sincronizado em 2026-08-07T13:48:22.052298+00:00

## Distribuição por status

### `ready` (12)

- [`t_02549f82`](./t_02549f82.md) — [kryx-cli] Investigar e corrigir metadata drift do 'kryx --version' (reporta 0.1
- [`t_0fa4e069`](./t_0fa4e069.md) — [kryxd][router][critical] KCR-ROUTER-1: corrigir mount v2 + remover duplo nest (
- [`t_3b1197fa`](./t_3b1197fa.md) — [kryxd][kryx][dead-code] KCR-TRANSLATOR-1: deletar translator.rs morto (455 LoC 
- [`t_690ebeeb`](./t_690ebeeb.md) — [KCR] Node Think Backend Unification — Strike 1 (Contrato e Tradutor)
- [`t_6e19cd19`](./t_6e19cd19.md) — [bug] kryx check: stub/incomplete wrapper
- [`t_86b3b38c`](./t_86b3b38c.md) — Define kryonix.features.node-server module skeleton
- [`t_8eff9891`](./t_8eff9891.md) — [kryxd][kryx][test] KCR-DESKTOP-ZFS-TEST: atualizar test pós-KCR-TEST-1 round-tr
- [`t_c5d06415`](./t_c5d06415.md) — [kryxd][test] KCR-CAPS-HARDCODE: derivar contagem de caps em vez de hardcodar 43
- [`t_ced1ea2f`](./t_ced1ea2f.md) — Analyze node-server flag translation in KCC executor
- [`t_d5fc7e89`](./t_d5fc7e89.md) — Define PXE boot architecture and KCC server configuration
- [`t_fcd2ec73`](./t_fcd2ec73.md) — [bug][kanban-ui] UI Kanban dessincronizada (estado vs display)
- [`t_fdf7f5df`](./t_fdf7f5df.md) — [bug][kryonix-guard] nix flake check quebrado em background

### `todo` (13)

- [`t_15532e6b`](./t_15532e6b.md) — Implement node-server flag handling in Axum executor
- [`t_16761a64`](./t_16761a64.md) — [infra] Validação E2E: Boot PXE físico (cliente diskless)
- [`t_2b0fe25a`](./t_2b0fe25a.md) — Validate node-server flag translation end-to-end
- [`t_311537a1`](./t_311537a1.md) — Implement DHCP server configuration (dhcpd/kea)
- [`t_49898d6e`](./t_49898d6e.md) — [kryxd][ui] Mover Node Server da tela Welcome para System Features
- [`t_707677ca`](./t_707677ca.md) — [kryonix][module] Implementar kryonix.features.node-server (PXE)
- [`t_79413498`](./t_79413498.md) — Implement unionfs for writable client overlay
- [`t_7fcccbaf`](./t_7fcccbaf.md) — Provision KCC server on physical hardware
- [`t_888671bd`](./t_888671bd.md) — Implement NFS/SquashFS root filesystem export
- [`t_b409dfcd`](./t_b409dfcd.md) — [kryxd][backend] Target node-server no InstallPlan executor
- [`t_d554bf0c`](./t_d554bf0c.md) — Implement TFTP server for PXE boot files
- [`t_df11083e`](./t_df11083e.md) — Validate clean PXE boot into RAM without local disk
- [`t_e19d900c`](./t_e19d900c.md) — Connect diskless physical client to network topology

### `scheduled` (71)

- [`t_01378724`](./t_01378724.md) — [kryx-cli] Motor de Identidade: validador de identity.json
- [`t_064d4632`](./t_064d4632.md) — mover seleção de Node Server da tela Welcome para tela feature
- [`t_06624529`](./t_06624529.md) — Configure MCP server exposure for local agents
- [`t_067eaf90`](./t_067eaf90.md) — Analisar trade-offs da migração BTRFS para ZFS no Inspiron
- [`t_06db0bff`](./t_06db0bff.md) — Ajustar isolamento de idioma e papel do host no wizard
- [`t_0784532c`](./t_0784532c.md) — Verificar carregamento do Gamescope via features.gaming.enable
- [`t_0d5d78db`](./t_0d5d78db.md) — [kryonix][kde] Padronização Visual: Ícones, Fontes e Cursores
- [`t_10f91ba9`](./t_10f91ba9.md) — Integrar Node Server como feature no InstallPlanV2
- [`t_14780942`](./t_14780942.md) — Document media storage implementation and Incus integration
- [`t_1a9f7c74`](./t_1a9f7c74.md) — Assegurar udev rules carregadas pelo feature flag gaming
- [`t_246f1e8e`](./t_246f1e8e.md) — Define identity.json schema and validation rules
- [`t_28b1cd48`](./t_28b1cd48.md) — Analisar cenário de perda de chaves CMOS e Secure Boot
- [`t_2a7319a2`](./t_2a7319a2.md) — Garantir montagem de zpool_home/data via configuração Flake
- [`t_2b5a2396`](./t_2b5a2396.md) — Implement WebSocket progress reporting to UI
- [`t_2efde2fa`](./t_2efde2fa.md) — Analyze ZFS/Btrfs dataset allocation requirements
- [`t_30ec3f62`](./t_30ec3f62.md) — Verify hermes user restrictions are enforced
- [`t_34da903f`](./t_34da903f.md) — Documentar estratégia de fallback para Secure Boot Keys
- [`t_3647abb4`](./t_3647abb4.md) — Consolidate media storage backend for ISO uploads
- [`t_379c129c`](./t_379c129c.md) — [tech-debt][home] kscreenlockerrc: LockGrace=10 default via Home Manager
- [`t_39aadf97`](./t_39aadf97.md) — Analyze Incus storage mapping for ISO image uploads
- [`t_3a080651`](./t_3a080651.md) — [kryxd] KVE (Debt): Task Engine e WebSocket
- [`t_3b8ed001`](./t_3b8ed001.md) — Atualizar disko.nix para configuração declarativa ZFS
- [`t_3ca5f41c`](./t_3ca5f41c.md) — [kryxd] KVE (Debt): Concluir Media Storage
- [`t_41900c05`](./t_41900c05.md) — Design async task tracking and WebSocket progress reporting architecture
- [`t_4bc1783e`](./t_4bc1783e.md) — Eliminar janelas legadas GTK2/Qt5 com fallback branco
- [`t_69522621`](./t_69522621.md) — [agents] Restrição de privilégios do usuário 'hermes'
- [`t_6c0701aa`](./t_6c0701aa.md) — Research and select unified icon theme package
- [`t_722f6ce0`](./t_722f6ce0.md) — [kryonixos] Fechar escopo do Perfil Gaming no Glacier
- [`t_74780195`](./t_74780195.md) — [kryonix] Topologia ZFS declarativa no Inspiron (NVMe 480GB)
- [`t_76df97eb`](./t_76df97eb.md) — Automatizar fallback de Secure Boot via kryonix
- [`t_7c4e7cb8`](./t_7c4e7cb8.md) — Analyze current hermes user permissions and access model
- [`t_7d952cf6`](./t_7d952cf6.md) — Implement 'kryx identity' subcommand
- [`t_815fe153`](./t_815fe153.md) — Configurar GRUB para modo texto limpo
- [`t_85b5741c`](./t_85b5741c.md) — Corrigir artefatos de renderização no tema escuro global
- [`t_8c05393d`](./t_8c05393d.md) — Mapear CLI para consumir API kryxd de forma declarativa
- [`t_8fb4d145`](./t_8fb4d145.md) — Remove unsupervised root access for hermes user
- [`t_91ddebbd`](./t_91ddebbd.md) — Integrate audit script into 'switch check' subcommand
- [`t_97b982f7`](./t_97b982f7.md) — Create audit verification script for nix and cargo checks
- [`t_99d0d2ff`](./t_99d0d2ff.md) — Add tests for identity validation
- [`t_9a65f64e`](./t_9a65f64e.md) — Validar consistência global do dark theme pós-correção
- [`t_a6973327`](./t_a6973327.md) — Package mcp-server-file-system in NixOS
- [`t_ad219342`](./t_ad219342.md) — [bug][kryonixos] hosts/glacier/hardware-configuration.nix:92 syntax error em fil
- [`t_ad9c33d3`](./t_ad9c33d3.md) — Research and select unified font packages for terminal and UI
- [`t_adbd3ed6`](./t_adbd3ed6.md) — [tech-debt][kanban-sync] smart sync: só atualiza last_sync_at se houve mudança r
- [`t_ae5ad7fd`](./t_ae5ad7fd.md) — [kryonix] Boot: estratégia de fallback para Secure Boot Keys
- [`t_b06f13e5`](./t_b06f13e5.md) — Validate safe read-only Kanban access in Obsidian Vault
- [`t_b1e7d239`](./t_b1e7d239.md) — [kryx-cli] Comando de auditoria: 'kryx switch check'
- [`t_b3973cef`](./t_b3973cef.md) — Configurar Plymouth para identidade visual única
- [`t_b4207e35`](./t_b4207e35.md) — Testar migração e boot com pool ZFS no Inspiron
- [`t_bc7e23b5`](./t_bc7e23b5.md) — [kryonix][kde] Plasma 6: Correção Global Dark Theme (base Kvuntu)
- [`t_bc88cf2c`](./t_bc88cf2c.md) — Validate dataset allocation against default pool
- [`t_bf1dcb27`](./t_bf1dcb27.md) — [agents] LightRAG: limitar resposta a Top-K=3 e 3000 caracteres
- [`t_c15b43ac`](./t_c15b43ac.md) — Implementar comando 'kryx virt ls' para listagem de VMs
- [`t_c50cf84e`](./t_c50cf84e.md) — Research and select unified cursor theme package
- [`t_c6b835a3`](./t_c6b835a3.md) — [kryonix][kde] Boot: Transição limpa GRUB → Plymouth → SDDM
- [`t_c8715a40`](./t_c8715a40.md) — Validar ambiente FHS do Steam sob features.gaming.enable
- [`t_cceb1a5d`](./t_cceb1a5d.md) — [kryonix] KVE (Debt): Validação de ZFS/Btrfs
- [`t_ce7567ea`](./t_ce7567ea.md) — Restrict hermes user write access to /etc directory
- [`t_dbe189e8`](./t_dbe189e8.md) — Implement declarative icon, font, and cursor config in Home Manager
- [`t_dd7972bb`](./t_dd7972bb.md) — Implementar comando 'kryx ct shell' para acesso a containers
- [`t_ddf2e17e`](./t_ddf2e17e.md) — Coordinate KVE resumption with Jenpex completion
- [`t_df8d3861`](./t_df8d3861.md) — [kryx-cli] Submódulos de virtualização (noun-verb)
- [`t_dfeb9a6a`](./t_dfeb9a6a.md) — Validar transição completa GRUB → Plymouth → SDDM
- [`t_eaa5417c`](./t_eaa5417c.md) — [agents] Integração MCP (Model Context Protocol) via NixOS
- [`t_eb10dca9`](./t_eb10dca9.md) — [tech-debt][kryonix] xdg.mimeApps motor vs user config (80+ vs 5 associacoes)
- [`t_ec77f116`](./t_ec77f116.md) — Auditar apps Qt6 e identificar artefatos de dark theme
- [`t_efa27cd0`](./t_efa27cd0.md) — Implement async task tracking for Incus instance creation
- [`t_f63be7e2`](./t_f63be7e2.md) — Consolidar escopo final do Perfil Gaming no Glacier
- [`t_f6ac831b`](./t_f6ac831b.md) — Add 'switch check' subcommand to kryx-cli
- [`t_fe75dae3`](./t_fe75dae3.md) — Implementar comando 'kryx vm start' para iniciar VMs
- [`t_ff1f9885`](./t_ff1f9885.md) — Configurar SDDM com tema customizado

### `done` (1)

- [`t_03e3dfb6`](./t_03e3dfb6.md) — [bug][critico] kryx switch aborta por clobber-protection do home-manager (mimeap

### `partial` (2)

- [`t_37589718`](./t_37589718.md) — Analyze impact of removing Node Server selection from Welcome screen
- [`t_aa0e609b`](./t_aa0e609b.md) — [enhancement] kryx check: wrapper de nix flake check para fluxo de agentes

### `superseded` (1)

- [`t_ac17626c`](./t_ac17626c.md) — [URGENCIA MAXIMA][bug][sist] kryx check inexistente + Guard quebra nix flake che

---
_Auto-gerado por `kanban-sync.py`._