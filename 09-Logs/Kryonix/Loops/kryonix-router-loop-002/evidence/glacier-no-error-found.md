# t_ad219342 — Investigation: NO syntax error found

**Date:** 2026-08-07
**Investigator:** Aura (sessão KCR-A — FASE 2)
**Outcome:** No-op. Card is spurious.
**Loop:** kryonix-router-loop-002
**Related card:** [[../../Cards/t_ad219342|t_ad219342]]

## What was claimed

`t_ad219342` claimed a syntax error at `hosts/glacier/hardware-configuration.nix:92` (FASE 2 of KCR-A, priority 2, blocker for CI).

## What was actually true (live evidence)

Probed live from `/home/rocha/Proyectos/kryonix-dev/repos/kryonixos` on `inspiron`, branch `main`, HEAD `05c7e81`, working tree clean.

**1. `nix flake check --keep-going --impure` passes for the whole repo:**

```bash
# bypass oficial do Kryonix Guard (validado 2026-07-30)
PATH="/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/usr/local/bin" \
  /run/current-system/sw/bin/nix --extra-experimental-features 'nix-command flakes' \
    flake check --keep-going --impure
```

Output (real):

```
evaluating flake...
checking flake output 'nixosConfigurations'...
checking NixOS configuration 'nixosConfigurations.inspiron'...
evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'
checking NixOS configuration 'nixosConfigurations.glacier'...
evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'
checking NixOS configuration 'nixosConfigurations.inspiron-nina'...
evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'
evaluation warning: `boot.zfs.forceImportRoot` is using the default value of `true`. It is highly recommended to set it to `false`, the new default from 26.11 on, to reduce the risk of data loss. Alternatively, you can silence this warning by explicitly setting it to `true`.
checking flake output 'homeConfigurations'...
all checks passed!
```

Exit code: 0. Glacier evaluated. No error at line 92. No error anywhere.

**2. Line 92 itself is syntactically valid:**

```nix
86|  fileSystems."/srv/downloads" = {
87|    device = "glacier-data/downloads";
88|    fsType = "zfs";
89|  };
90|
91|  fileSystems."/srv/games" = {
92|    device = "glacier-data/games";
93|    fsType = "zfs";
94|  };
```

Identical pattern to the 10 other `fileSystems.*` blocks above and below (lines 32–47, 50–53, 55–62, 64–68, 70–73, 75–79, 81–84, 86–89, 96–99, 101–104, 106–109, 111–114, 116–119). All have `;` at end of every `fsType` assignment, `;` at end of every closing `}`, and consistent 2-space indent.

**3. History of the file shows no recent fix-me commits:**

```
6627ee4 feat(glacier): declare secondary ZFS datasets and swap
5dd2caf fix(glacier): align ZFS root and EFI mounts
bfe585b feat(glacier): migracao canonica para ZFS, CachyOS, GRUB e Incus
74cfd6b feat(downstream): migração completa de hosts e home pessoais
```

The `6627ee4` commit is likely the one that introduced the block containing line 92 (the `/srv/games` dataset). No follow-up "fix syntax" commit in history.

**4. Working tree was clean before this investigation:**

```
$ git -C .../kryonixos status --short
(empty)
```

## Remaining warnings (pre-existing, NOT this card's scope)

These warnings appeared in the flake check output but are **not** the same issue as the alleged syntax error:

| Warning | Source | Affected file | Status |
|---|---|---|---|
| `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'` | kryonix motor (input) | input modules, not hosts/glacier | Pre-existing, motor team's scope |
| `boot.zfs.forceImportRoot` using default `true` | NixOS 26.11 cosmetic | kryonix motor (ZFS module) | Pre-existing, cosmetic |

Neither is a syntax error. Both are evaluation warnings. Neither blocks CI evaluation.

## Probable cause

The card was opened by an agent (Codex/Claude?) that either:

- **A.** Read a stale `nix flake check` output from a previous, broken state.
- **B.** Misclassified an evaluation warning as a syntax error.
- **C.** Analyzed a pre-merge snapshot of `hosts/glacier/hardware-configuration.nix` that was already corrected by commit `6627ee4`.
- **D.** Hallucinated the location based on a different file (e.g., the upstream `kryonix` motor, not the `kryonixos` downstream).

## Action taken

- Investigation completed. No code change applied.
- Diff is empty; nothing to commit.
- Card `t_ad219342` should be marked as `done` with result `NO_OP` (not `FEATURE_DELIVERED` — this is not delivered work, this is a no-op investigation). Pending human gate before mutation.

## Card mutation proposal (awaits human gate)

Following the `kryonix-kanban-triage` skill Governance mode (read-only Orchestrator → propose exact mutation → wait for human OK):

```bash
# Via SQLite-direct (clis `kanban_update`/`kanban_complete` are mnemonic, not real — pitfall #25)
python3 -c "
import sqlite3, time, json
db = sqlite3.connect('/home/rocha/.hermes/kanban/boards/kryonix/kanban.db')
db.row_factory = sqlite3.Row
now = int(time.time())
notes = ('No-op investigation 2026-08-07 (KCR-A FASE 2). '
         'nix flake check passes, line 92 is valid syntax, working tree clean. '
         'Symptom does not reproduce. Likely spurious card from previous agent. '
         'Evidence: 09-Logs/Kryonix/Loops/kryonix-router-loop-002/evidence/glacier-no-error-found.md')
db.execute('UPDATE tasks SET status = ?, result = ?, completed_at = ? WHERE id = ?',
          ('done', 'NO_OP', now, 't_ad219342'))
db.commit()
db.execute('''INSERT INTO task_events (task_id, run_id, kind, payload, created_at)
              VALUES (?, ?, ?, ?, ?)''',
          ('t_ad219342', None, 'completed',
           json.dumps({'result': 'NO_OP', 'notes': notes}), now))
db.commit()
"
```

Then sync the card file to vault:

```bash
kanban-sync --card t_ad219342 --quiet
```

Do NOT run `kanban-sync --quiet` (full sync) — that would rewrite 90+ files with timestamp-only changes (pitfall #33). Surgical `--card` only.

## Lesson learned (for future KCR-A FASE N)

Before applying any fix in KCR-A, validate the pre-condition. If `nix flake check` passes, there is no syntax error to fix.

The deeper lesson: **cards inherit claims from prior agents; claims are not evidence.** Always probe the runtime before trusting the card body. The cost of a no-op investigation (3 tool calls, <5s) is far less than the cost of a fake fix (commited diff, polluted PR, WRONG result on closed card).

## Related

- Loop: `kryonix-router-loop-002`
- Card: `t_ad219342`
- Active loop state: [[../STATE.md]]
- Workspace: `/home/rocha/Proyectos/kryonix-dev/repos/kryonixos`
- Bypass command: AGENTS.md §6 Kryonix Guard bypass
