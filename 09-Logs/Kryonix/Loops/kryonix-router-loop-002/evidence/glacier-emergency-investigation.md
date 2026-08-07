# Glacier emergency mode — diagnostic playbook

> **Para:** Gabriel (executar no console físico do glacier)
> **Quando:** cair no shell de emergency mode ANTES de pressionar Ctrl+D
> **Loop:** kryonix-router-loop-002
> **Criado:** 2026-08-07 (checkpoint durante pausa de 13h)

## Sintoma

Boot cai em `emergency.target`. **`Ctrl+D` (`systemctl default`) desbloqueia e vai pro `graphical.target`**. Máquina usável, mas com barulho no boot.

**Tradução:** não é boot quebrado. Um unit não-crítico falha, systemd desce pro emergency pra perguntar, e Ctrl+D tenta o default de novo sem o unit que falhou.

## Quando reproduzir

- Glacier ligado
- Cair no prompt de emergency ANTES de Ctrl+D
- Ter mídia de captura (pen drive, ssh, foto) disponível

## Sequência diagnóstica (5 comandos)

```bash
# 1. Captura log de erro (cola o conteúdo pra mim)
journalctl -xb -p err --no-pager | tail -80 > /tmp/emergency-log.txt
cat /tmp/emergency-log.txt

# 2. Lista units failed (cola)
systemctl list-units --failed --no-pager

# 3. Dependências quebradas de multi-user.target (cola)
systemctl list-dependencies multi-user.target --no-pager | grep -E "not-found|failed"

# 4. Status do hermes-agent (cola)
systemctl status services.hermes-agent --no-pager

# 5. Status do NM-wait (cola)
systemctl status NetworkManager-wait-online.service --no-pager
```

## Suspeitos prioritários (em ordem de probabilidade)

| # | Unit | Por que falha | Fix típico |
|---|---|---|---|
| 1 | `services.hermes-agent.service` | `podman` sem sudo NOPASSWD pra `rocha`, ou imagem `ubuntu:24.04` não baixada | `sudo loginctl enable-linger rocha` + baixar imagem manualmente, OU trocar `container.backend` pra `docker` |
| 2 | `NetworkManager-wait-online.service` | `rve-compat.nix` faz `networkmanager.enable = false` mkForce, mas algum profile do kryonix puxa NM-wait por cima → conflito | Remover `Wants=NetworkManager-wait-online.service` do `network-online.target` ou desabilitar o serviço |
| 3 | `tailscaled.service` | `authKeyFile = /root/tailscale-authkey.secret` não existe | Criar o arquivo com a key, ou desabilitar `autoconnect` |
| 4 | `zfs-mount.service` | Dataset `glacier-system/nix` ou `glacier-system/ROOT` indisponível | `zpool import -N` para diagnóstico, depois `zfs mount -a` |
| 5 | `ollama.service` | Modelo `qwen2.5:7b` não baixado, falha em start | `ollama pull qwen2.5:7b` manualmente, ou desabilitar `loadModels` |

**Suspeito #1 (hermes-agent) é o mais provável** porque houve **2 commits recentes** endireçando isso:

- `cc21fa9 fix(glacier): allow passwordless sudo for podman to access hermes-agent container`
- `24b0ffb fix(glacier): revert hermes-agent container backend to podman`

Esses commits mostram que **o problema é recorrente e ainda não totalmente resolvido**.

## Por que Ctrl+D funciona

`systemctl default` tenta subir o `default.target` (geralmente `graphical.target`). Se o unit que falhou tem `WantedBy=` em algum target intermediário (não 100% required), `default` pula ele por tolerância. Por isso tu acaba no SDDM sem o unit rodando.

## Próximo passo (depois dos 5 outputs)

Com os 5 outputs colei pra Aura, identificar:

1. **Qual unit aparece em `systemctl list-units --failed`** — esse é o culpado.
2. **Linha exata do erro** no `journalctl -p err` — esse é o **porquê**.
3. **Fix cirúrgico de 1-3 linhas** na config NixOS OU override do unit file.

Fix típico (a confirmar dependendo do output):

```nix
# Se for hermes-agent falhando:
services.hermes-agent.container.enable = lib.mkForce false;
# ou
users.users.rocha.extraGroups = [ "podman" ];

# Se for NM-wait conflito:
systemd.services.NetworkManager-wait-online.enable = false;

# Se for tailscaled:
services.kryonix.tailscale.autoconnect = false;
```

## ⚠️ Não fazer daqui

- **NÃO aplicar fix sem ter os 5 outputs.** É cego.
- **NÃO rebootar o glacier remotamente.** Pode regredir.
- **NÃO editar `/etc/kryonixos` direto.** Editar no workspace (`/home/rocha/Proyectos/kryonix-dev/repos/kryonixos/hosts/glacier/`), commit, PR, depois sync via `sudo git pull --ff-only`.

## Rollback

Se algum fix piorar a situação, rollback via boot por geração anterior:

```bash
# No console do glacier, em emergency mode:
nix-env --list-generations --profile /nix/var/nix/profiles/system
# Identifica a geração boa (ex: 47)
nix-env --switch-generation 47 --profile /nix/var/nix/profiles/system
systemctl reboot
```

## Referências

- AGENTS.md do kryonixos: "glacier é headless + KRDP, não validado em hardware. Aplicar só com console/SSH garantido — risco de lockout."
- Top 5 suspeitos originais (pré Ctrl+D): descartados porque Ctrl+D provê que boot não está quebrado
- Estado prévio do source: `hosts/glacier/{default,hermes,rve-compat}.nix` lidos em 2026-08-07
