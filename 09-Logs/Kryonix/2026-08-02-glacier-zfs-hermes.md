# Correção ZFS Glacier e Integração Hermes/Ollama

Data: 2026-08-02
Agente: Antigravity
Repos afetados:
- kryonixos (Glacier configuration)
- kryonix (Brain/Ollama fix)

## Objetivo
1. Estabilizar a inicialização do ZFS no host Glacier (evitando emergency mode na montagem de pools adicionais).
2. Integrar o agente Hermes ao Ollama local (`qwen2.5:7b`).

## Contexto consultado
- Configuração canônica de ZFS do `inspiron` (uso de `devNodes = "/dev/disk/by-id"`).
- Regras de override do systemd que causavam race conditions no startup dos ZFS Mounts.
- Atualização NixOS sobre `services.ollama.modelsDir`.

## Mudanças realizadas
1. **ZFS Boot**: Adicionado `boot.zfs.devNodes = "/dev/disk/by-id";` no `hosts/glacier/storage.nix`.
2. **Systemd**: Removidos overrides nocivos de `zfs-mount.after` e `local-fs.after` em `hosts/glacier/default.nix`, delegando a ordem de boot nativamente ao NixOS.
3. **Hermes AI**: Adicionado bloco LLM apontando para Ollama local em `hosts/glacier/hermes.nix` (`http://127.0.0.1:11434`, modelo `qwen2.5:7b`).
4. **Nixpkgs API Fix**: No core repo (`kryonix`), corrigido uso legado de `models` para `modelsDir` no `modules/nixos/services/brain.nix` referente ao serviço Ollama.

## Commits e branches
(Pendente commit final no `kryonixos` e `kryonix` na branch main).

## Validações executadas
- Executado `nix flake check --keep-going` nos repositórios afetados.
- Build estático do toplevel do glacier.

## Evidências
(Será verificado pós-reboot se o glacier subiu sem emergency mode e se Hermes interage usando Ollama).

## Pendências
- N8N: A integração foi paralisada até a clarificação dos webhooks e credenciais requeridas, de forma a não expor toolsets vazios ou inválidos no Hermes.

## Próximo passo recomendado
Rebootar Glacier, inspecionar `zpool status`, checar os logs de `hermes-agent.service` e iniciar delineamento do blueprint N8N.
