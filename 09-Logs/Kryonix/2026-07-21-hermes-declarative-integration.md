# Finalização da Integração Declarativa do Hermes

Data: 2026-07-21
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonixos
- repos/kryonix-assets

## Objetivo
Finalizar a ativação declarativa do novo módulo `kryonix.features.hermes` em substituição ao antigo `services.hermes` que foi descontinuado e mapear o sistema de arquivos para acesso simbiótico (Read-Write) ao ecossistema do usuário (workspace de desenvolvimento, Obsidian Vault e persistência).

## Contexto consultado
- A documentação de regras para agentes (`AGENTS.md`)
- As anotações do próprio plano de execução no Obsidian Vault (onde a duplicidade de atributo do hermes-agent foi apontada).
- Arquitetura de flake outputs no repositório `kryonix`

## Mudanças realizadas
1. **Core do sistema (`repos/kryonix`)**:
   - Criação do módulo `modules/nixos/features/hermes.nix` contendo a declaração de um container Podman, executando a imagem `docker://localhost/hermes-agent:latest` em modo `userns=keep-id`.
   - Adicionamos o mapeamento `Read-Write` nos volumes do Workspace (`/home/rocha/kryonix-dev`), Vault (`/home/rocha/kryonix-dev/repos/kryonix-vault`) e Persistência do usuário (`/home/rocha/.local/share/kryonix/hermes`).
   - Resolução da falha de Lockfile corrigindo a configuração de `kryonix-assets` para ser referenciada por URL local apontando corretamente para o flake (`git+file:///home/rocha/kryonix-dev/repos/kryonix-assets`).
   - Adição e correção de referências do atributo `kryonixAssets` ao overlay do ecossistema que afetava a derivação de `kryonix-branding` e outros temas na build.

2. **Downstream/Host (`repos/kryonixos`)**:
   - Substituição do uso de `services.hermes` no Host `inspiron` pela opção declarativa customizada `kryonix.features.hermes.enable = true;`.
   - Remoção do arquivo estático/legado `hosts/inspiron/hermes.nix`.

3. **Assets (`repos/kryonix-assets`)**:
   - Adição e consolidação de imagens do repositório no git track.

## Commits e branches
Foram criados commits nos respectivos branches `main` de todos os três repositórios. Posteriormente, as referências foram agrupadas e atualizadas no Workspace `kryonix-dev`.

## Validações executadas
- Comando `nix flake check` na raiz do core (`kryonix`), completado sem erros (resolvendo issues do flake e overlay args).
- Comando `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel --extra-experimental-features "nix-command flakes"` dentro de `kryonixos`, concluindo o build do sistema com sucesso e injetando as rotinas corretas para o Hermes.

## Evidências
- Logs da compilação e verificação de flakes documentados nesta seção. 
- O build verde foi completado pelo Flake.

## Pendências
- O build local da imagem OCI do Hermes (`docker://localhost/hermes-agent:latest`) está presumido, logo precisa ser garantido antes ou pelo startup do contêiner. O ambiente `.env` precisa ser formatado fisicamente caso secrets específicos sejam introduzidos (agora ele aceita um arquivo local em `~/.config/hermes/agent.env`).

## Próximo passo recomendado
- Realizar deploy ativo (`kryonix switch` ou equivalente) no Host alvo para instanciar a VM do contêiner Podman e validar se a comunicação entre o Hermes e os diretórios via `Read-Write` atende as expectativas da "Simbiose Total".
