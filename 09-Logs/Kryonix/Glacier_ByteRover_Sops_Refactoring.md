# Refatoração Glacier: Sops-Nix, ByteRover SSOT e Otimização VRAM (RTX 4060)

Data: 2026-09-20
Agente: Antigravity / Kryonix Systems Specialist
Repos afetados:

- `repos/kryonix`
- `repos/kryonixos`
- `repos/kryonix-vault`

## Objetivo

Refatorar a infraestrutura do host `glacier` no ecossistema Kryonix, migrando a gestão de segredos para `sops-nix`, removendo infraestrutura legada de memória (Hindsight e outros provedores de grande footprint) e configurando o **ByteRover** (`brv`) de forma 100% declarativa como o único provedor de memória do Hermes Agent, totalmente alinhado com as restrições de hardware do host (RTX 4060 8GB VRAM / 16GB System RAM).

## Contexto Consultado

- `repos/kryonixos/hosts/inspiron/default.nix` (Padrão sops-nix + age)
- `repos/kryonixos/hosts/glacier/default.nix` e `hermes.nix`
- `repos/kryonix-vault/02-Areas/NixOS/Secrets.md`
- `AGENTS.md` (Regras de commit em 2 etapas e validação de submódulos)

## Mudanças Realizadas

1. **Engine Core (`repos/kryonix`)**:
   - Criado `packages/byterover.nix`: Derivação do CLI `brv` (ByteRover) para gerenciamento de árvore de contexto e memória local em arquivos Markdown.
   - Atualizado `flake/packages.nix`: Exportados os pacotes `byterover` e `brv`.

2. **Downstream Systems (`repos/kryonixos`)**:
   - Criado `secrets/glacier.yaml`: Arquivo sops-nix criptografado para o host `glacier`.
   - Atualizado `hosts/glacier/default.nix`:
     - Importado `inputs.sops-nix.nixosModules.sops`.
     - Adicionada configuração `sops` apontando para `../../secrets/glacier.yaml` e `/home/garton/.config/sops/age/keys.txt`.
     - Otimizado `services.ollama`:
       - `acceleration = "cuda"` habilitado.
       - `OLLAMA_NUM_PARALLEL = "1"`, `OLLAMA_MAX_LOADED_MODELS = "1"`, `OLLAMA_FLASH_ATTENTION = "1"`.
       - **Crucial**: `OLLAMA_CONTEXT_SIZE = "4096"` para limitar `num_ctx` a 4096 tokens, impedindo que a RTX 4060 (8GB VRAM) faça fallback para a RAM do sistema (16GB).
   - Atualizado `hosts/glacier/hermes.nix`:
     - Removido `"hindsight"` do `extraDependencyGroups`.
     - Atualizado `environmentFiles = [ config.sops.secrets."hermes-env".path ]`.
     - Configurado `settings.memory.provider = "byterover"` com salvamento em Markdown local (`/var/lib/kryonix/hermes/memory`).
     - Apontada conexão LLM para o endpoint OpenAI-compatible do Ollama local (`http://127.0.0.1:11434/v1`).
     
   - Atualizado `users/garton/glacier/default.nix`:
     - Importado `inputs.hermes-agent.homeManagerModules.default`.
     - Adicionado `byterover` (`brv`) e `sops` em `home.packages`.
     - Declaradas as configurações `~/.hermes/config.yaml` e `~/.config/byterover/config.yaml`.
     - Criado serviço systemd do usuário `byterover-init` para executar `brv providers connect openai-compatible --base-url http://localhost:11434/v1` no boot.

## Validações Executadas

- Build do pacote `byterover` no Kryonix engine via bypass oficial do Guard (`nix build .#byterover`).
- Validação estática dos flakes Nix (`nix flake check`).

## Evidências

- `nix build .#byterover` gerou o executável `/nix/store/...-brv/bin/brv`.
- Configuração do Ollama aplicando `OLLAMA_CONTEXT_SIZE = "4096"` de forma imutável.
