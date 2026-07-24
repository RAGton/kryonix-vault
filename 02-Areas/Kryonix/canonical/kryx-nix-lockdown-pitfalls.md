# kryx + cli-lockdown: pitfalls & resolutions

> **Status:** Canônico · **Atualizado:** 2026-07-23
> **Skill relacionada:** `~/.hermes/skills/devops/kryx-nix-lockdown-pitfalls/SKILL.md`
> **Sessão de origem:** rebuild completo kryx-cli 2026-07-23 (commits `bf4a056`..`0c47578`)

---

## TL;DR

Cinco bugs com `nix`/`nh`/libgit2 custaram ~3h de debug até serem resolvidos.
**Em qualquer sessão futura, leia esta nota ANTES de mexer no kryx.**

Sintomas → causa → fix na tabela:

| Sintoma | Causa | Fix |
|---|---|---|
| `[Kryonix Guard] O comando 'nix' foi bloqueado` | `Command::new("nix")` resolve pro wrapper | `discover_real_nix()` no Rust (caminho absoluto) |
| `Don't run nh os as root` | nh 4.x recusa euid==0 | `setpriv --reuid=UID --regid=UID --clear-groups` (sem sudo) |
| `failed to stat /root/.gitconfig (libgit2 error code = 7)` | HOME=/root via sudo + libgit2 fallback paths | inject `GIT_CONFIG_*=/dev/null` no Command::env() + `/home/$user/.gitconfig` |
| `mismatch in field 'lastModified'` | lock manual sem timestamp correto | `nix flake metadata --json github:.../COMMIT` |
| `libc 0.2.189 not found in vendor` | `cargo add libc` + lock sem update | `cargo update -p libc` + commit ambos |

---

## 1. Contexto: o que é o cli-lockdown

O módulo `kryonix.security.cliLockdown` instala **wrappers de erro**
em `~/.nix-profile/bin/` (via `home.packages`, **não** em
`environment.systemPackages` — isso preservaria os binários da Store).

Comandos bloqueados no shell interativo:
- `nix`
- `nixos-rebuild`
- `nh`
- `nix-shell`

**Objetivo:** impedir que usuário rode comandos Nix "selvagens" sem
passar pelo ecossistema kryx (kryx switch / kryx update / kryx shell).

**Problema:** o `kryx` CLI precisa **chamar esses binários internamente**
pra fazer o trabalho. Sem path absoluto, qualquer `Command::new("nix")`
cai no wrapper e quebra.

**Por que `home.packages` e não `systemPackages`?** Porque `home.packages`
mascara APENAS no shell interativo do usuário. Subprocessos do sistema
(kryx daemon, kryx switch chamado via sudo) **não herdam** esses wrappers
— eles usam `/run/current-system/sw/bin/` direto, que tem os binários
reais.

**Lockdown v2 (commit `7b57ffbe`):** moveu wrappers de
`environment.systemPackages` → `home.packages` pra preservar os binários
da Store que estavam sendo sobrescritos pelo lockdown v1.

---

## 2. Os 5 bugs em detalhe

### Bug #1: `nix` command "bloqueado" em kryx internals

**Quando acontece:** `kryx doctor` chama `nix eval` para checar
`config.networking.hostId` e `services.zfs.trim.enable`.

**Sintoma:**
```
[WARN] zfs        hostid               nix saiu com exit status: 1:
  [Kryonix Guard] O comando 'nix' foi bloqueado.
  Use o ecossistema kryx para gerenciar o sistema.
```

**Causa:** `Command::new("nix")` em `src/services/diagnostics.rs` faz
PATH lookup. O PATH do root tem `~/.nix-profile/bin` antes de
`/run/current-system/sw/bin` (quando invocado via `kryx doctor`
interativo). Resolved = wrapper.

**Fix:** `discover_real_nix()` que escaneia `/nix/store`, acha o nix real
(>1MB, vs ~400 bytes do wrapper) e usa path absoluto.

```rust
// src/services/diagnostics.rs
#[inline(never)]  // OBRIGATÓRIO: sem isso LTO descarta a função
fn discover_real_nix() -> Option<String> {
    let entries = std::fs::read_dir("/nix/store").ok()?;
    let mut best: Option<String> = None;
    for entry in entries.flatten() {
        let name = entry.file_name().to_string_lossy().to_string();
        if !name.contains("-nix-2.") { continue; }
        let bin = entry.path().join("bin/nix");
        let meta = match std::fs::metadata(&bin) {
            Ok(m) => m, Err(_) => continue,
        };
        // Lockdown wrappers are ~400 bytes; real nix is several MB.
        if meta.len() < 1_000_000 { continue; }
        let path = bin.to_string_lossy().to_string();
        if best.as_ref().map_or(true, |b| path > *b) {
            best = Some(path);
        }
    }
    best
}
```

**Gotchas críticos:**
1. `#[inline(never)]` é **obrigatório** — sem ele o linker descarta a
   função por dead-code-elimination. Sintoma: rebuild passa mas
   `kryx doctor` ainda bloqueia. Verificar com:
   ```bash
   strings /path/to/kryx | grep -c discover_real_nix
   # Esperado: 1+ (não 0)
   nm /path/to/kryx | grep -c discover_real_nix
   # Esperado: 1+ (não 0)
   ```

2. **NÃO** comparar por `meta.modified()` (mtime) — em ZFS ou sandboxes
   o mtime pode não estar acessível, e o `?` retorna `None` que vira
   fallback pro nome `nix` → wrapper bloqueado. Use lexicographic
   comparison (último hash ganha).

**Aplicar em:** qualquer chamada de `nix eval`, `nix flake`, `nix build`
dentro do kryx (especialmente `doctor`, `system report`, `identity`
quando precisar de info do flake).

---

### Bug #2: `nh` recusa rodar como root

**Quando acontece:** `kryx switch` chama `nh os switch`.

**Sintoma:**
```
Error:
   0: Don't run nh os as root. It will escalate its privileges internally as needed.
Location:
   crates/nh-nixos/src/nixos.rs:1172
```

**Causa:** nh 4.x tem checagem `euid == 0` hardcoded que sai com erro.

**Fix:** o kryx re-dropa privilégios para o SUDO_USER original antes
de chamar nh, usando `setpriv` (Linux capability, **não sudo**).

```rust
// src/services/modules.rs (run_switch)
use std::os::unix::fs::PermissionsExt;

let sudo_user = std::env::var("SUDO_USER").unwrap_or_else(|_| "rocha".to_string());
let needs_redrop = unsafe { libc::geteuid() == 0 };

let mut cmd = if needs_redrop {
    // Resolve UID do SUDO_USER via /etc/passwd
    let user_id: u32 = parse_uid_from_passwd(&sudo_user).unwrap_or(1000);

    let mut c = Command::new("/run/current-system/sw/bin/setpriv");
    c.arg(format!("--reuid={}", user_id))
     .arg(format!("--regid={}", user_id))
     .arg("--clear-groups")
     .arg("/run/current-system/sw/bin/nh")
     .arg("os").arg("switch")
     .arg("--elevation-strategy")
     .arg("/run/wrappers/bin/sudo")  // nh escala SÓ pro bootloader
     .arg(format!("/etc/kryonixos#{}", hostname));
    c
} else {
    let mut c = Command::new("/run/current-system/sw/bin/nh");
    c.arg("os").arg("switch")
     .arg("--elevation-strategy")
     .arg("/run/wrappers/bin/sudo")
     .arg(format!("/etc/kryonixos#{}", hostname));
    c
};

cmd.env("PATH", real_nix_dir + ":" + current_path)
   .env("HOME", format!("/home/{}", sudo_user))
   .env("GIT_CONFIG_GLOBAL", "/dev/null")
   .env("GIT_CONFIG_SYSTEM", "/dev/null")
   .env("GIT_CONFIG_NOSYSTEM", "1");
```

**Por que `setpriv` e não `sudo -u`?**
- `sudo -u` aplica `env_reset` que strippa `GIT_CONFIG_*` mesmo com
  `env HOME=...` inline
- `setpriv` é Linux capability nativa, sem política de env
- O `kryx` **nunca** deve invocar `sudo` internamente — só o `nh` faz
  isso (e só pra ativação do bootloader)

**Requisito do nh:** `/home/$SUDO_USER/.gitconfig` deve existir
(ver Bug #3).

**Requisito do Rust:** `libc` no `Cargo.toml`:
```toml
[dependencies]
libc = "0.2"
```

---

### Bug #3: `failed to stat /root/.gitconfig (libgit2 error code = 7)`

**Quando acontece:** nh (via libgit2) durante flake evaluation.

**Sintoma:**
```
error: opening Git repository "/etc/kryonixos":
  failed to stat '/root/.gitconfig' (libgit2 error code = 7)
```

**Causa tripla:**
1. kryx roda com `HOME=/root` (porque é invocado via `sudo kryx ...`)
2. `/root/.gitconfig` não existe OU tem permissões 700
3. libgit2 (dentro do nh) chama `getenv("HOME")` mas o wrapper do nh
   faz `setenv("HOME", "/root")` por baixo dos panos

**Fix em 3 camadas (todas necessárias):**

**Camada 1 — Inject env vars:**
```rust
cmd.env("GIT_CONFIG_GLOBAL", "/dev/null")
   .env("GIT_CONFIG_SYSTEM", "/dev/null")
   .env("GIT_CONFIG_NOSYSTEM", "1");
```

**Camada 2 — Set HOME pro home do user:**
```rust
cmd.env("HOME", format!("/home/{}", sudo_user));
```

**Camada 3 — Garantir /home/$user/.gitconfig:**
```bash
# Rodar uma vez:
cat > /home/rocha/.gitconfig <<'EOF'
[user]
    name = Gabriel
    email = gabriel@example.com
[init]
    defaultBranch = main
[safe]
    directory = *
EOF
```

**Caveat sobre chmod 755 /root:** é band-aid temporário. **NÃO confie**
só nele. Aplique os 3 fixes. O chmod pode ser resetado por activation
scripts do NixOS.

**Diagnóstico rápido:**
```bash
# Verifica se o problema é /root
ls -ld /root  # drwx------  = bug #3 (resolva com os 3 fixes)
              # drwxr-xr-x = ok, problema é outro

# Verifica se .gitconfig do user existe
test -f /home/rocha/.gitconfig || echo "FALTA .gitconfig no /home/rocha"
```

---

### Bug #4: `lastModified` mismatch no flake.lock

**Quando acontece:** ao editar `/etc/kryonixos/flake.lock` manualmente
pra apontar pra um commit específico (workaround quando o lockdown
bloqueia `nix flake update`).

**Sintoma:**
```
error: mismatch in field 'lastModified' of input
  '{"lastModified":0,"owner":"RAGton","repo":"kryx-cli","rev":"..."}',
  got '{"lastModified":1784857140,...}'
```

**Causa:** Nix usa um timestamp específico (do Nix Store metadata, não
do git). GitHub API pode retornar valor diferente.

**Fix:** use **sempre** `nix flake metadata --json`:

```bash
NIX=/nix/store/q816a9ipng9dkdnp1n30pi39ag977zj6-nix-2.35.1/bin/nix
$NIX flake metadata --json github:RAGton/kryx-cli/$COMMIT_SHA
# Output: {"revision": "SHA_COMPLETO", "lastModified": 1784857140, ...}
```

O campo `revision` é o SHA completo (40 chars), `lastModified` é
epoch Unix em segundos.

**Anti-pattern:** usar `gh api repos/.../commits/...` — o `committer.date`
do GitHub pode diferir do que o Nix usa (que é o timestamp do Nix
Store metadata, não do git).

**Python helper:**
```python
import json, subprocess
result = subprocess.run(
    [NIX, "flake", "metadata", "--json", f"github:RAGton/kryx-cli/{REV}"],
    capture_output=True, text=True
)
data = json.loads(result.stdout)
full_rev = data["revision"]           # full SHA
real_lastmod = data["lastModified"]   # epoch

# Update lock
for name, node in lock["nodes"].items():
    if node.get("original", {}).get("repo") == "kryx-cli":
        node["original"]["rev"] = full_rev
        node["locked"]["rev"] = full_rev
        node["locked"]["lastModified"] = real_lastmod
        node["locked"].pop("narHash", None)  # força re-fetch
        break
```

**Aplicar em:** qualquer vez que precisar forçar uma versão específica
de input no flake.lock (workaround pra `nix flake update` bloqueado).

---

### Bug #5: `libc 0.2.189 not found in vendor`

**Quando acontece:** ao adicionar `libc` como dep pro `geteuid()`.

**Sintoma:** Nix build falha com:
```
error: failed to select a version for the requirement `libc = "^0.2.189"`
candidate versions found which didn't match: 0.2.187
```

**Causa:** `cargo add libc` escolhe a versão mais recente (0.2.189) e
adiciona no `Cargo.toml`, mas o `Cargo.lock` em outros clones ainda tem
0.2.187. Nix constrói com `--offline` (não baixa nada) e dá mismatch.

**Fix:**
```bash
cargo update -p libc  # atualiza o lock pra 0.2.189
# Commit AMBOS: Cargo.toml E Cargo.lock
git add Cargo.toml Cargo.lock
git commit -m "fix: bump libc to 0.2.189"
```

**Anti-pattern:** commitar só o `Cargo.toml` — o lock fica dessincronizado
e o Nix build quebra com mensagem confusa.

---

## 3. Workflow correto de rebuild (kryx switch)

```bash
# 1. Edita código em ~/Proyectos/kryonix-dev/repos/kryx-cli
# 2. Build release
cd ~/Proyectos/kryonix-dev/repos/kryx-cli
cargo build --release

# 3. Testar localmente antes de commitar
cd /tmp && sudo ./target/release/kryx doctor

# 4. Commit + push (paths explícitos!)
git add src/services/foo.rs  # NUNCA git add .
git commit --no-gpg-sign -m "fix(kryx): ..."
git push origin HEAD:main

# 5. Atualiza /etc/kryonixos/flake.lock (Python helper acima)

# 6. Switch com binário NOVO (do target/release)
sudo /home/rocha/Proyectos/kryonix-dev/repos/kryx-cli/target/release/kryx switch

# 7. Validar
sudo /run/current-system/sw/bin/kryx doctor
```

**Por que target/release e não o do Nix?** O `/run/current-system/sw/bin/kryx`
é o **antigo** (do build Nix anterior). Pra rebuildar com o código novo,
**precisa** usar o target/release que acabou de ser buildado. É o
chicken-and-egg de cada rebuild.

---

## 4. Pre-flight checks antes de qualquer kryx work

```bash
# /root deve ser atravessável (chmod 755)
sudo ls -ld /root  # drwxr-xr-x ...

# /home/rocha/.gitconfig deve existir
test -f /home/rocha/.gitconfig || cat > /home/rocha/.gitconfig <<'EOF'
[user]
    name = Gabriel
    email = gabriel@example.com
[safe]
    directory = *
EOF

# nix real tem que ser > 1MB
ls -l /nix/store/*-nix-2.*/bin/nix | head -3  # procurar pelo path

# /run/wrappers/bin/sudo deve ser setuid
ls -l /run/wrappers/bin/sudo
# Esperado: -rwsr-xr-x (s = setuid)

# binário kryx atual
md5sum /run/current-system/sw/bin/kryx

# testes rápidos
sudo kryx --version
sudo kryx doctor 2>&1 | tail -3
```

**Se algum desses falhar**, consulte a seção 2 antes de debugar.

---

## 5. Lições para evitar no futuro

1. **Nunca** use `git add .` — sempre paths explícitos (regra do AGENTS.md)
2. **Nunca** `nix flake update` interativamente — gera lastModified aleatório
3. **Sempre** `nix flake metadata --json` antes de editar lock
4. **Sempre** `cargo build --release` antes de tentar `kryx switch`
5. **Sempre** `cargo update` depois de `cargo add`
6. **Nunca** commite `Cargo.toml` sem `Cargo.lock` (e vice-versa)
7. **Sempre** `#[inline(never)]` em funções de helper chamadas uma vez
8. **Sempre** documente a sessão no vault (regra do AGENTS.md)
9. **Sempre** teste o doctor/status DEPOIS de cada switch
10. **Sempre** cheque `ls -ld /root` antes de debugar erros de libgit2

---

## 6. Comandos proibidos sem autorização

(do AGENTS.md do kryonix-dev)
- `git add .`
- `git reset --hard`
- `git clean -fdx`
- `git push --force`
- `nix flake update` (use `nix flake metadata`)
- `nixos-rebuild switch` (use `kryx switch`)
- `reboot` / `poweroff`

---

## 7. Verificação rápida depois de qualquer mudança

```bash
sudo kryx doctor 2>&1 | tail -5
# Esperado: 16 PASS, 5 WARN, 1 FAIL (kryx-telemetry se ainda parado)

sudo kryx status 2>&1 | head -30
# Esperado: dashboard expandido com CPU/mem/network/services/security

sudo kryx completion bash | head -3
# Esperado: script de completion começa com _kryx()

sudo kryx shell --help
# Esperado: usage info sem bloqueio
```

Se algum comando retornar `[Kryonix Guard] bloqueado`, consulte Bug #1.

---

## 8. Commits relacionados

| Commit | Mensagem |
|---|---|
| `7b57ffbe` | fix(security): cli-lockdown uses home.packages instead of systemPackages |
| `aa1f0e1` | feat(cli): Switch/Update com Fail-Fast + Break-Glass flags |
| `bf4a056` | fix(kryx): sanitize git env vars em todos subprocessos nativos |
| `ef794e1` | fix(kryx): sudo -u + env injeta GIT_CONFIG_* (nh recusa root) |
| `d0fe1e7` | fix(kryx): re-dropa privilégios com setpriv, nunca usa sudo |
| `6e41373` | fix(kryx): update Cargo.lock to include libc 0.2.189 |
| `569b496` | fix(kryx-doctor): bypass cli-lockdown ao chamar nix eval |
| `c8b11a9` | feat(kryx-status): expande dashboard com CPU, mem, network, services, security |
| `0c47578` | feat(kryx-doctor): adiciona 5 areas de check (cpu, memory, disk, services, security) |

---

## 9. Referências

- [Skill Hermes `kryx-nix-lockdown-pitfalls`](file:///home/rocha/.hermes/skills/devops/kryx-nix-lockdown-pitfalls/SKILL.md)
- [Log sessão 2026-07-23](file:///home/rocha/Proyectos/kryonix-dev/repos/kryonix-vault/09-Logs/Kryonix/2026-07-23-kryx-nix-lockdown-debug-session.md)
- AGENTS.md do kryonix-dev (regras gerais)
- `kryonix/modules/nixos/lib/cli-lockdown/default.nix` (o módulo que causa o lockdown)
- `kryx-cli/src/services/modules.rs` (run_switch — bug #2 e #3)
- `kryx-cli/src/services/diagnostics.rs` (kryx doctor — bug #1, #3)
- `kryx-cli/src/services/status.rs` (kryx status — herdou os fixes)
- `kryx-cli/src/services/update.rs` (kryx update — bug #3)
- `kryx-cli/src/services/passthrough.rs` (wrappers kryx shell/etc — bug #3)
