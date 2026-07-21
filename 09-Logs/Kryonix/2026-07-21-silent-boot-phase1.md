# Phase 1: Silent Boot and Plymouth Decoupling

Data: 2026-07-21
Agente: Antigravity / Claude
Repos afetados:
- repos/kryonix

## Objetivo
Implementar a fundação da experiência de boot visual e fluida do Kryonix OS. Esta fase focou na inicialização silenciosa do Kernel (Initrd) e supressão completa do texto de console (Silent Boot), transicionando diretamente para a animação do Plymouth, evitando logs de console ou flicker na tela, respeitando as boas práticas declarativas do NixOS.

## Contexto consultado
- Revisado a estruturação de módulos e a separação entre `branding` e as configurações estritas de inicialização.
- Avaliado os conflitos do `nouveau` com instâncias utilizando placas gráficas NVIDIA em driver proprietário.
- Inspecionado as necessidades de instâncias isoladas (como os servidores `glacier`) que não devem herdar configurações de inicialização puramente visuais.

## Mudanças realizadas
- **Módulo de Boot:** Criado `modules/nixos/boot/silent-boot.nix` que injeta estritamente parâmetros silenciosos (`quiet splash loglevel=3 rd.udev.log_level=3 rd.systemd.show_status=false`), permitindo habilitar/desabilitar `earlyKms`. A injeção de `nouveau` foi condicionada a estar sem a configuração `modesetting.enable` da Nvidia ativada.
- **Exportação:** Exportado no índice de módulos de NixOS, via `flake/modules.nix` (na tag `boot`).
- **Ativação por Perfil:** Ativado no perfil reutilizável `profiles/desktop.nix` usando o recurso injetado, permitindo que todas as estações herdem esta característica visual sem afetar servidores/infraestrutura.
- **ISO:** Refatoração de `hosts/iso/default.nix` apagando declarações pontuais espalhadas de plymouth e substituídas por `kryonix.boot.silent.enable = true`.
- **Branding:** Simplificada a injeção do Plymouth no módulo de branding (`modules/nixos/branding/kryonix/default.nix`), usando `lib.mkDefault true` para o `boot.plymouth.enable`.

## Commits e branches
- Criado novo commit `feat(boot): add declarative silent-boot module and plymouth decoupling` no `repos/kryonix` na branch principal (`main`).
- Commit de atualização do pointer do submodule `kryonix` em `kryonix-dev`.

## Validações executadas
- Avaliado `nix flake show` para consistência e verificação de hosts e módulos.
- Build executada e validada no host virtualizado da ISO `nixosConfigurations.iso.config.system.build.toplevel`, comprovando a integridade e parsing da infraestrutura silenciosa.

## Evidências
- Compilação realizada com sucesso sob `/nix/store` da geração `iso`.

## Pendências
- O testamento em VM completa final (Desktop `inspiron`) precisa ser realizado assim que o repositório `kryonixos` espelhar estas alterações locais.
- Necessário dar andamento nas Fases 2 (SDDM) e 3 (Painel React).

## Próximo passo recomendado
Atualizar a Fase 2 integrando componentes visuais robustos baseados em SDDM conforme escopado na discussão inicial de modernização estética (Plymouth para Desktop Session).
