# Enterprise Gateway Auth & Dynamic Cluster Tree

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Implementar a primeira versão do KCP Enterprise Auth Gateway com sessão efêmera em formato JWT-like assinado e transformar a TreeView Proxmox-like de mock estático para mapeamento dinâmico baseado nos endpoints de virtualização e storage.

## Contexto consultado

- `repos/kryxd/src/api/mod.rs`
- `repos/kryxd/src/api/v1/mod.rs`
- `repos/kryxd/src/api/v1/rbac.rs`
- `repos/kryxd/src/api/virt.rs`
- `repos/kryxd/src/api/storage.rs`
- `repos/kryxd/ui/src/App.jsx`
- `repos/kryxd/ui/src/lib/api.js`
- `repos/kryxd/ui/src/components/kcp/TreeView.jsx`
- `repos/kryxd/Cargo.toml`

## Mudanças realizadas

### Backend

- Criado `src/api/auth.rs`.
- Adicionadas rotas:
  - `POST /api/v1/auth/login`
  - `GET /api/v1/auth/session`
- Login valida usuário permitido (`admin`, `gabriel`, `root`) e senha derivada de forma mock robusta:
  - se `KRYONIX_AUTH_PASSWORD` existir, usa essa senha;
  - caso contrário, deriva senha efêmera a partir do `identity.uuid` sem expor o valor.
- Sessão emitida como token compacto com header/payload/signature, assinado via HMAC-SHA256 implementado localmente com `sha2`.
- Cookie de sessão:
  - `HttpOnly`
  - `SameSite=Strict`
  - `Path=/`
  - `Max-Age=900`
- `RequireCoreRole` agora lê sessão via Cookie ou `Authorization: Bearer`, mantendo fallback de identidade local para compatibilidade com validações existentes.
- `GET /api/v2/virt/instances` foi habilitado como alias read-only para a listagem atual do Incus.

### Frontend

- Criado `ui/src/pages/Login.jsx` com tela premium escura:
  - `bg-slate-950`
  - card central com `rounded-2xl`, `border-white/5`, `bg-slate-900/50`, `backdrop-blur-md`
  - logo animado Kryonix e acentos azul cobalto
  - inputs com `bg-slate-950`, `border-slate-800`, `focus:border-blue-500`
- Atualizado `ui/src/lib/api.js`:
  - `loginGateway()`
  - `getSession()`
  - `getVirtInstances()`
  - wrapper `requestJson()` com `credentials: 'same-origin'`
- Atualizado `ui/src/App.jsx`:
  - rota `/login`
  - `RequireSession`
  - Dashboard legado e rotas `/kcp` protegidos por sessão
  - usuário sem sessão é redirecionado para `/login`
- Atualizado `ui/src/components/kcp/TreeView.jsx`:
  - remove nós hardcoded da Fase 1
  - executa `Promise.all([getVirtInstances(), getStoragePools()])`
  - renderiza pools e instâncias vindas da API
  - preserva estilo Proxmox-like dark/tree

## Commits e branches

- Nenhum commit feito.
- Nenhum push feito.
- Nenhum pointer de submódulo atualizado.

## Validações executadas

- `cargo check --workspace` — passou.
  - Aviso conhecido do workspace: resolver virtual ainda em `resolver = "1"` com membros edition 2024.
- `npm run build --prefix repos/kryxd/ui` — passou.
  - Avisos conhecidos: `/img/noise.png` não resolvido em build time e chunk JS > 500 kB.
- Verificação ad-hoc fresca em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou; script temporário removido após execução (`cleanup ok`).
- A verificação ad-hoc também removeu `ui/dist` gerado pelo Vite.
- `git diff --check` escopado — passou.
- Checagem Vault Strict para raiz do `kryxd` — sem `implementation_plan.md`, `task.md` ou `*.log` criados na raiz.

## Evidências

Resultado da verificação ad-hoc:

```txt
AD-HOC VERIFY ENTERPRISE AUTH GATEWAY + DYNAMIC TREE: PASS
- /api/v1/auth/login and /api/v1/auth/session markers exist with HttpOnly SameSite session cookie
- session token verification accepts Authorization Bearer or session cookie and RBAC reads it
- /api/v2/virt/instances GET is available for TreeView mapping
- Login.jsx contains premium dark gateway UI and calls loginGateway
- App.jsx redirects unauthenticated protected KCP/dashboard routes to /login
- TreeView fetches virt instances and storage pools with Promise.all and no Fase 1 hardcoded resources
- cargo check --workspace passed
- npm production build passed; generated ui/dist was removed
- scoped git diff --check passed
- Vault Strict root draft/log offenders absent in kryxd
```

Diff/status escopado observado:

```txt
M src/api/mod.rs
M src/api/v1/mod.rs
M src/api/v1/rbac.rs
M src/api/virt.rs
M ui/src/App.jsx
M ui/src/lib/api.js
?? src/api/auth.rs
?? ui/src/components/kcp/TreeView.jsx
?? ui/src/pages/Login.jsx
```

## Riscos e limites

- A implementação de sessão é uma primeira camada local/installer-oriented; para produção multiusuário, o ideal é integrar PAM/LDAP/OIDC ou backend de identidade real.
- O login mockado depende de `KRYONIX_AUTH_PASSWORD` para credencial humana previsível; sem essa variável, a senha é derivada do `identity.uuid` e não é exibida.
- O RBAC ainda mantém fallback por `identity.json` para não quebrar testes/fluxos existentes; endurecer para sessão obrigatória deve ser uma fase separada.
- `GET /api/v2/virt/instances` ainda reutiliza a listagem Incus existente baseada em comando `incus list --format=json`; migração para API local Incus read-only fica como evolução futura.

## Addendum arquitetural — Proxmox vs KCP

A direção arquitetural registrada para o KCP é superar o padrão Proxmox-like sem copiar seu backend legado.

### Referência Proxmox

- Proxmox usa `pmxcfs` + Corosync para replicar o estado de `/etc/pve` entre nós.
- Esse modelo entrega uma experiência operacional forte, mas combina FUSE, C/Perl e quorum sensível à latência.
- A leitura útil para o KCP é o paradigma UX/operacional: resource tree, estado global e ações contextuais; não o reuso direto do código Perl/ExtJS.

### Direção Kryonix

- O KCP deve usar o Incus como hypervisor e consumir a topologia real via API.
- O estado de cluster deve se apoiar no cluster nativo do Incus/dqlite/Raft quando disponível, com NixOS declarando o baseline e o KCP operando como plano de controle.
- Não clonar monorepos do Proxmox por padrão; se for necessário estudar Proxmox, preferir documentação/API/layouts específicos com forte isolamento de contexto.

### Storage HA

- Sanoid/Syncoid continua útil para backup/DR assíncrono, mas não deve ser vendido como HA síncrono de datacenter.
- Para HA real de blocos e failover de VM, a direção proposta é estudar Ceph RBD como fundação do Storage Command Center.
- Próxima decisão pendente: desenhar um planner declarativo de preseed/configuração Ceph sem executar mutações destrutivas.

## Pendências

- Pré-visualizar `/login` no navegador com mock API atualizado.
- Decidir política definitiva de senha inicial/bootstrapping para ISO real.
- Endurecer RBAC para sessão obrigatória quando a migração de frontend estiver completa.
- Conectar TreeView a dados reais de cluster distribuído quando o backend de cluster estiver definido.
- Decidir se a próxima fase será `Ceph Foundation` ou acoplamento do `xterm.js` em `/kcp/node/:nodeId/vm/:vmId/console`.

## Próximo passo recomendado

Rodar a prévia visual e validar ergonomia do Login Gateway + TreeView dinâmica antes de qualquer commit.
