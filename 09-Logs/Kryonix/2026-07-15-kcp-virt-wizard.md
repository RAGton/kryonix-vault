# KCP Virt Wizard Implementado

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryonix-installer (UI e Backend)
- kryonix (Kryx Engine)

## Objetivo
Implementar o fluxo de provisionamento de instâncias (VMs e Contêineres LXC) diretamente pelo Dashboard do KCP, usando uma experiência multi-step similar ao Proxmox.

## Contexto consultado
Rotas originais do Axum, wrapper de CLI do Incus e Design System da UI (`lucide-react`, cores `kryonix-blue`).

## Mudanças realizadas
1. **Motor Rust (`virt_engine.rs`)**:
   - Criação da `InstanceConfig` com `serde`.
   - Modificação estrutural no `incus_launch` para traduzir o struct nas diretrizes `-c limits.cpu`, `-c limits.memory`, e `-d root,size` do LXD/Incus.

2. **API Axum (`virt.rs`)**:
   - Refatoradas as rotas legadas (`/container`, `/vm`) para um endpoint unificado `POST /instances` que consome a serialização direta de `InstanceConfig`.

3. **Frontend (`VirtWizard.jsx`)**:
   - Componente React Modal com controle de passos (General, OS, Specs, Confirm).
   - Design System `bg-gray-800` para formulários e `kryonix-blue` para botões e acentos ativos.

4. **Integração (`Virt.jsx` & `api.js`)**:
   - Correção do endpoint de listagem no Client HTTP para apontar perfeitamente ao `/api/v2/virt/nodes`.
   - Inserido o disparo do `<VirtWizard />` no click de "Nova Instância" com "auto-refresh" das instâncias na tabela pai após a conclusão da API.

## Validações executadas
- `cargo check` rodado localmente validou as mudanças de domínio do struct em ambos os worktrees.
- O bundler do Frontend gerou os artefatos com sucesso.
