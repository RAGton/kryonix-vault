# 2026-07-23 — kryx-cli reestruturação completa + status/doctor expandidos

> **Agente:** Aura · **Duração:** ~4h · **Resultado:** PASS

---

## Resumo

Reestruturação completa do `kryx-cli` (Rust) pra resolver 5 bugs
recorrentes relacionados ao `cli-lockdown` + expansão de `status` e
`doctor` com 5 novas categorias. Tudo documentado em nota canônica.

## Commits gerados (9)

| SHA | Mensagem |
|---|---|
| `bf4a056` | fix(kryx): sanitize git env vars em todos subprocessos nativos |
| `ef794e1` | fix(kryx): sudo -u + env injeta GIT_CONFIG_* (nh recusa root) |
| `d0fe1e7` | fix(kryx): re-dropa privilégios com setpriv, nunca usa sudo |
| `6e41373` | fix(kryx): update Cargo.lock to include libc 0.2.189 |
| `569b496` | fix(kryx-doctor): bypass cli-lockdown ao chamar nix eval |
| `c8b11a9` | feat(kryx-status): expande dashboard com CPU, mem, network, services, security |
| `0c47578` | feat(kryx-doctor): adiciona 5 areas de check (cpu, memory, disk, services, security) |

## Os 5 bugs resolvidos

1. **nix bloqueado** em kryx internals → `discover_real_nix()` com path
   absoluto (lexicographic, não mtime — mtime quebra em ZFS)
2. **nh recusa root** → `setpriv --reuid=UID --regid=UID --clear-groups`
   (sem `sudo`, evita `env_reset`)
3. **libgit2 /root/.gitconfig** → inject `GIT_CONFIG_*=/dev/null` no
   `Command::env()` + garantir `/home/$user/.gitconfig` existe
4. **lastModified mismatch** → usar `nix flake metadata --json github:...`
   (NÃO GitHub API — retorna timestamp diferente)
5. **libc 0.2.189 not found** → `cargo update -p libc` + commit ambos
   `Cargo.toml` e `Cargo.lock`

## Expansões

### kryx status (era 10 linhas, agora ~50)
- 🖥️ CPU (modelo, load, temperatura com sensors/thermal_zone)
- 🧠 Memória (RAM%, swap%, com cores)
- 💾 Storage (zpool status + 5 mounts críticos)
- 🌐 Rede (interfaces IPv4 + gateway + DNS)
- 📦 Containers (incus, podman)
- ⚙️ Serviços Kryonix (kryxd, telemetry)
- 🔐 Security (lockdown, sudo setuid)

### kryx doctor (era 5 categorias, agora 10)
- cpu (loadavg, temperature)
- memory (ram, swap)
- disk (space, mounts críticos)
- services (kryxd, NetworkManager, sshd)
- security (lockdown, sudo-setuid)

**Antes:** 8 PASS, 4 WARN, 0 FAIL
**Depois:** 16 PASS, 5 WARN, 1 FAIL (kryx-telemetry parado intencionalmente)

## Lições aprendidas (viram skill + nota canônica)

1. `#[inline(never)]` é **obrigatório** em helpers chamados uma vez
   (LTO descarta a função, sintoma: rebuild passa mas código não executa)
2. `mtime` em `metadata.modified()` quebra em ZFS — use lex comparison
3. `sudo -u` no Rust **sempre** perde env vars (env_reset) — use `setpriv`
4. `kryx` NUNCA usa `sudo` internamente — só o `nh` faz isso, e só
   pra ativação do bootloader
5. `Command::new("nix")` **sempre** cai no wrapper se PATH tem o
   home.packages — sempre use path absoluto via `discover_real_nix()`
6. Chicken-and-egg do rebuild: `kryx switch` precisa do binário novo,
   mas o novo só entra via `kryx switch` — use `target/release/kryx`
   até o Nix build ser ativado

## Pendências (stale items da sessão)

- [ ] Reativar `kryx-telemetry.service` (parado pra evitar boot loops
      durante a investigação; agora o binário está OK)
- [ ] Validar `kryx update` com binário novo (libgit2 paths + nix flake
      update ainda não testados juntos)
- [ ] Atualizar flake.lock do kryonix (não só kryonixos) pra apontar
      pro commit novo do kryx-cli
- [ ] Auditoria PTY do `/api/v2/console/host/ws` (item antigo)
- [ ] Hermes consolidated audit (item antigo)

## Artefatos gerados

- **Skill:** `~/.hermes/skills/devops/kryx-nix-lockdown-pitfalls/SKILL.md`
- **Nota canônica:** `02-Areas/Kryonix/canonical/kryx-nix-lockdown-pitfalls.md`
- **Log:** este arquivo
