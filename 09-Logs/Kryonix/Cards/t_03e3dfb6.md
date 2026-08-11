---
card_id: t_03e3dfb6
status: done
type: 
priority: 0
created_at: 2026-07-30T14:21:40+00:00
started_at: 2026-07-30T14:22:31+00:00
completed_at: 2026-08-07T03:19:08+00:00
last_sync_at: 2026-08-07T19:38:07.073423+00:00
last_kanban_state: done
result: FEATURE_DELIVERED
auto_generated: true
audits:
  - kanban-drift-2026-08-04
---

# [bug][critico] kryx switch aborta por clobber-protection do home-manager (mimeapps.list)

**Card:** `t_03e3dfb6` | **Status:** `done`

## Descrição

## Sintoma

`kryx switch` (que internamente roda `nh os switch`) termina o build com sucesso (13/13 OK, 1m01s) mas a ativação do sistema falha durante o reload do `home-manager-rocha.service`:

```
> Activating configuration
Error: Activation (test) failed
Activation failed (exit status ExitStatus(Exited(4)))
activating the configuration...
reloading user units for rocha...
restarting the following user units: nixos-activation.service
restarting sysinit-reactivation.target
the following new units were started: NetworkManager-dispatcher.service, systemd-localed.service
warning: the following units failed: home-manager-rocha.service

Location:
   crates/nh-core/src/command.rs:907
Erro Crítico: nh os switch abortado ou falhou com status: exit status: 1
```

## Causa raiz (confirmada via journalctl)

`home-manager-rocha.service` entra em `checkLinkTargets` e aborta porque o backup padrao do home-manager (`*.hm-bak-kryonix`) colidiria com um backup pre-existente:

```
Activando checkLinkTargets
Please do one of the following:
- In standalone mode, use 'home-manager switch -b backup' to back up files automatically.
- When used as a NixOS or nix-darwin module, set either
  - 'home-manager.backupFileExtension', or
  - 'home-manager.backupCommand',
  to move the file to a new location in the same directory, or run a custom command.
- Set 'force = true' on the related file options to forcefully overwrite the files below.
  eg: xdg.configFile."mimeapps.list".force = true
Existing file '/home/rocha/.config/mimeapps.list.hm-bak-kryonix' would be clobbered
  by backing up '/home/rocha/.config/mimeapps.list'
home-manager-rocha.service: Main process exited, code=exited, status=1/FAILURE
```

Falha repetida em 3 tentativas durante a mesma ativacao (journal mostra 3 inicializacoes, todas `exit 1`).

## Historico do problema

Ja houve correcao em commit previo (`c7c741d`) com `force = true` em `xdg.mimeApps`, depois **revertida** em `7a7be84` ("Revert fix(home): force xdg.mimeApps to bypass hm-bak clobber protection"). Resultado: o `kryx switch` voltou a quebrar.

```
adc3866 docs(kryonixos): use kryx runtime binary, note alias
7a7be84 Revert "fix(home): force xdg.mimeApps to bypass hm-bak clobber protection"  <- causa
c7c741d fix(home): force xdg.mimeApps to bypass hm-bak clobber protection
a6864f9 chore(flake): bump kryonix upstream to e426756 (V69a deps + kryonix.kcp facade)
0780398 merge(glacier): gamer profile + hermes backend fix
```

## Estado atual do filesystem

```
/home/rocha/.config/mimeapps.list                            (2009 B, 30/07 10:12) - gerenciado
/home/rocha/.config/mimeapps.list.hm-bak-kryonix              (1922 B, 26/07 19:24) - BLOQUEANDO
/home/rocha/.config/mimeapps.list.hm-bak-kryonix-20260722-194020
/home/rocha/.config/mimeapps.list.hm-bak-kryonix.old
/home/rocha/.config/mimeapps.list.hm-bak-kryonix.old-20260724
/home/rocha/.config/mimeapps.list.hm-bak-kryonix.old-20260724-101328
/home/rocha/.config/mimeapps.list.hm-bak-kryonix.old-20260724-153024
/home/rocha/.config/mimeapps.list.hm-bak.pre-switch-20260721-153005
/home/rocha/.config/mimeapps.list.hm-bak.pre-switch-20260721-202311
/home/rocha/.config/mimeapps.list.hm-bak.pre-switch-20260722-082417
/home/rocha/.config/mimeapps.list.hm-bak.pre-switch-20260722-112912
```

Acumulo de lixo (~10 arquivos `.hm-bak*`) revertendo o `force = true` abriu caminho para colidir a cada `kryx switch`.

## Ambiente

- Host: **inspiron** (ThinkServer), `/etc/kryonixos` (git tree, dirty = so `flake.lock`)
- Sistema: `26.11.20260719.241313f (Zokor)`
- nh: `4.4.1`
- kryonix-upstream: `e426756` (V69a deps + kryonix.kcp facade)
- Nix store: `PATHS 3407 -> 3407`, `SIZE 43.3 GiB -> 43.3 GiB` (apenas rebuild, sem realocacao)
- Avaliacao avisou: `system has been renamed to/replaced by stdenv.hostPlatform.system` (deprecation, nao bloqueia)

## Por que o cartao e "critico"

`kryx switch` e o UNICO caminho de transicao atomica do host. Quando ele falha, qualquer reboot pode deixar o sistema em estado inconsistente porque a nova geracao nao foi ativada. O dirty tree warning (`git status: M flake.lock`) e independente e deve ser tratado em outro cartao.

## Criterio de aceitacao (definicao de "resolvido")

1. `kryx switch` executa build + ativacao ate `Finished activating` sem erro.
2. `systemctl --user status home-manager-rocha.service` retorna `active (exited)`.
3. `git -C /etc/kryonixos log --oneline -3` mostra o commit de fix no lugar (e o revert SOME).
4. Smoke test: `kryx status` retorna host integro.

## Estrategia de fix recomendada (a decidir pelo Arquiteto)

3 alternativas, cada uma com trade-off. **Eu iria pela (A)** porque e a unica que sobrevive a multiplos switches sem precisar de manutencao manual.

### (A) Restaurar o `force = true` em `xdg.mimeApps` (re-aplicar `c7c741d`)

- Vantagem: fim do problema em definitivo, logica declarativa, sem alias manual.
- Custo: o backup anterior (`.hm-bak-kryonix` de 26/07) precisa ser **removido manualmente** uma vez antes do proximo switch, ou o conflito persiste.

### (B) Configurar `home-manager.backupFileExtension` global

- Adicionar `home-manager.backupFileExtension = ".hm-bak.${config.home.username}"` no modulo.
- Vantagem: isola backups por hostname/usuario, nao acumula.
- Custo: muda nome dos arquivos, eventualmente quebra scripts que assumem `*.hm-bak-kryonix`.

### (C) Limpar o lixo `.hm-bak*` acumulado + reativar sem mexer no flake

- `rm ~/.config/mimeapps.list.hm-bak-*` (10 arquivos).
- Vantagem: 0 alteracao no flake, baixo risco.
- Custo: bug volta no proximo switch quando o `mimeapps.list` mudar de novo.

## Nao-objetivos

- Nao vamos reescrever Plasma config.
- Nao vamos tocar em `kryonix-waywallen` (buildou limpo no ultimo switch).
- Nao vamos consertar o dirty tree do `flake.lock` (cartao separado).
- Nao vamos migrar para um home-manager-side activation script novo.

## Validacao pendente (workspace seguro)

- [ ] `kryx switch --dry-run` (se a flag existir) para validar avaliacao
- [ ] Aplicar (A) ou (C)
- [ ] `journalctl --user -u home-manager-rocha.service -n 20` deve mostrar `succeeded`
- [ ] `git -C /etc/kryonixos status --short` apos ativacao (espera: limpo ou so `flake.lock`)

## Riscos

- Estrategia (A) remove o backup existente do mimeapps - se a config nova tiver associacao errada, Gabriel perde o estado anterior. Mitigacao: `cp ~/.config/mimeapps.list.hm-bak-kryonix ~/mimeapps.list.rescue` antes do switch.
- Estrategia (C) nao conserta a causa raiz; voltaremos aqui em 2-4 semanas.

## Rollback

- Snapshots ZFS do host estao habilitados (verificar `zfs list -t snapshot` antes de mexer).
- kryonix-upstream permanece em `e426756` durante o trabalho - sem bump de flake.

## Contexto de producao

- `/etc/kryonixos` esta em PROD. Nunca editar direto; fluxo e DEV -> commit -> PR -> `kryx switch` (este que esta quebrado).
- Lockdown: **sem** `git reset --hard`, `nix-collect-garbage -d`, `nixos-rebuild switch`, system restart sem Gate L3.

## Result

`FEATURE_DELIVERED`

## Execução timestamps

- **Iniciado:** `2026-07-30T14:22:31+00:00`
- **Concluído:** `2026-08-07T03:19:08+00:00`

## Assignment

- **Criado por:** `user`
- **Assignee:** `aura-decision`

## Workspace

`/home/rocha/.hermes/kanban/boards/kryonix/workspaces/t_03e3dfb6`

## Audits

This card is part of the following audit(s):

- `[kanban-drift-2026-08-04](../Audits/kanban-drift-2026-08-04/STATE.md)` — **Kanban × Vault drift audit** (2026-08-04)
  - 7 cards flagged for drift; 1 urgent (clobber-protection), 6 batch-reopen
## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-08-07T03:19:08+00:00` | `completed` | {"result": "FEATURE_DELIVERED", "notes": "Fix validado em produ\u00e7\u00e3o. PR #15 mergeado (commit 05c7e81). nh home switch exit 0, 1320 paths rebuilt, sem .hm-bak-* criado. 1 linha de patch em kry... |
| `2026-08-02T12:51:00+00:00` | `commented` | {"author": "orchestrator", "len": 633} |
| `2026-08-02T12:50:59+00:00` | `assigned` | {"assignee": "aura-decision"} |
| `2026-08-02T12:46:47+00:00` | `commented` | {"author": "default", "len": 764} |
| `2026-07-30T15:07:57+00:00` | `commented` | {"author": "default", "len": 513} |
| `2026-07-30T15:07:56+00:00` | `commented` | {"author": "default", "len": 372} |
| `2026-07-30T14:37:53+00:00` | `commented` | {"author": "default", "len": 4999} |
| `2026-07-30T14:32:41+00:00` | `block_loop_detected` | {"reason": "Gate humano: bug diagnosticado. Estrategia (A) escolhida: reaplicar c7c741d + cleanup controlado do .hm-bak-kryonix. Aguardando intervencao manual do Arquiteto.", "kind": null, "recurrence... |
| `2026-07-30T14:32:41+00:00` | `commented` | {"author": "default", "len": 169} |
| `2026-07-30T14:32:40+00:00` | `unblocked` | None |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `286` | blocked | blocked | 2026-07-30T14:32:41+00:00 | 2026-07-30T14:32:41+00:00 |
| `285` | scheduled | scheduled | 2026-07-30T14:32:23+00:00 | 2026-07-30T14:32:23+00:00 |
| `284` | blocked | blocked | 2026-07-30T14:28:31+00:00 | 2026-07-30T14:28:41+00:00 |
| `283` | reclaimed | reclaimed | 2026-07-30T14:22:31+00:00 | 2026-07-30T14:28:13+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T19:38:07.073427+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._