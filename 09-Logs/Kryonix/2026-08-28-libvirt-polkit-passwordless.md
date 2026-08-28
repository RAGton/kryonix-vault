# Configuração de Polkit para Libvirt Sem Senha

Data: 2026-08-28
Agente: Antigravity / Gemini
Repos afetados:
- `repos/kryonix`
- `kryonix-dev` (submodule pointer)

## Objetivo
Resolver a solicitação de autenticação via senha (dialog PolicyKit "Normativa del sistema previene gestión de sistemas virtualizados locales") ao interagir com o daemon `libvirt` via `virsh`, `virt-manager` ou scripts de automação.

## Contexto Consultado
- `repos/kryonix/modules/nixos/features/virtualization.nix`
- Screenshot do usuário indicando a ação Polkit `org.libvirt.unix.manage`.

## Mudanças Realizadas
- Adicionada regra explicita em `security.polkit.extraConfig` no módulo `repos/kryonix/modules/nixos/features/virtualization.nix` liberando ações `org.libvirt.unix.*` sem requisição de senha (`polkit.Result.YES`) para usuários pertencentes ao grupo `libvirtd`.

## Commits e Branches
- `repos/kryonix`: `fix(virtualization): fix polkit option name from extraRules to extraConfig` (`79f96446`)

## Validações Executadas
- `PATH="/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/usr/local/bin" /run/current-system/sw/bin/nix --extra-experimental-features 'nix-command flakes' flake check --keep-going --impure` (Passou sem erros)

## Evidências
Módulo compilado e validado via Flake Check.

## Próximo Passo Recomendado
- Rodar `kryx switch` ou `nixos-rebuild switch` no host para aplicar a nova regra de Polkit no sistema ativo.
