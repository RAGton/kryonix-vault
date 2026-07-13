# Refatoração do RAGOS Think para Service Provider (mkKryonixService)

Data: 2026-07-13
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonix-vault

## Objetivo
Desacoplar o RAGOS Think do núcleo do sistema e transformá-lo em um Service Provider modular, eliminando a concorrência pela escrita livre na raiz do `/etc` e impedindo que scripts legados (como o do instalador) injetem configurações indiscriminadamente.

## Contexto consultado
O instalador do RAGOS (legado, em bash) gerava configurações como `wan-pppoe.env` em `/etc/ragos/` e arquivos de ambiente (`params.nix`, `hardware-configuration.nix`) em `/var/lib/ragos/runtime/`. A arquitetura exigia que essas injeções seguissem um modelo de "Guarda de Fronteira".

## Mudanças realizadas
1. **Helper `mkKryonixService`**: Criado em `lib/services.nix` e exportado em `lib/default.nix`. Ele garante que os módulos escrevam apenas no seu namespace `/etc/kryonix/services/<nome_do_servico>/` via `environment.etc`, criando links simbólicos legados via `system.activationScripts` quando estritamente necessário.
2. **Módulo Declarativo**: Adicionado `modules/services/ragos/default.nix` definindo `options.kryonix.services.ragos-think`. Este módulo faz uso do helper `mkKryonixService` para popular `params.nix` e `wan-pppoe.env` (caso configurado com PPPoE).
3. **Flake Output**: Exportado o módulo `services-ragos` em `flake/modules.nix` do core.

## Validações executadas
- `nix flake check --keep-going` rodou com sucesso (`all checks passed!`) no `repos/kryonix`.

## Pendências
- O instalador em Rust (`kryonix-installer`) e a interface (React/Vite) precisam ser atualizados futuramente para fornecer um JSON compativel e aplicar o profile que habilita `kryonix.services.ragos-think.enable = true` no target, sem rodar scripts shell para configuração do RAGOS.

## Próximo passo recomendado
Atualizar o repositório `kryonix-installer` para delegar a responsabilidade de configurações RAGOS ao nix, chamando a interface do novo módulo.
