# KCR-KCP-2026-07-PROXMOX-UI-CLONE — Tree-View + Contextual Tabs

Data: 2026-07-16
Agente: Aura
Status: proposta registrada; execução ainda não iniciada
Repos previstos:

- kryxd
- kryonix-vault

## Objetivo

Registrar a proposta de refatoração visual do KCP para abandonar o layout de dashboard genérico e adotar uma experiência orientada a objetos no estilo Proxmox/vSphere: árvore de recursos à esquerda, contexto com abas à direita e navegação profunda por URL.

## Contexto

A análise compara:

- Proxmox VE: ExtJS, resource tree, context panel com tabs e task log.
- Kryonix KCP: React + Tailwind + React Router, backend Rust/Axum e Incus REST API como camada de virtualização.

A intenção é fazer o KCP parecer e operar como software de gerenciamento de servidor/data center, não como SaaS genérico.

## Change Request

```md
# MISSÃO: Refatoração de UI - Clone da Experiência Proxmox (Tree-View)

Objetivo: Abandonar o layout de dashboard genérico e implementar o padrão "Tree-View + Contextual Tabs" na interface do KCP, inspirado na UX do Proxmox, utilizando React e Tailwind.

## 1. O Componente Árvore (Sidebar)
- **Local:** `ui/src/components/kcp/TreeView.jsx` (Novo)
- Construa uma barra lateral (Left Pane) retrátil e escura (`bg-kryonix-dark`).
- Implemente uma estrutura de árvore expansível (Accordion).
- **Estrutura Base:**
  - 🖥️ **Datacenter**
    - 📦 **Nodes**
      - 🖥️ `local-node` (o host atual)
        - 🗄️ `local-zfs` (Storage)
        - 💻 `100 (vm-web)` (VM Incus)
        - 📦 `101 (ct-db)` (Container Incus)
- *Dica:* Por enquanto, faça um fetch em `getVirtNodes()` e `getStoragePools()` (da `api.js`) para montar os nós filhos do `local-node`.

## 2. O Layout de Abas Contextuais (Right Pane)
- **Local:** `ui/src/layouts/ContextLayout.jsx` (Novo)
- Este componente será renderizado na área principal quando um item da árvore for clicado.
- Ele deve conter um cabeçalho com o nome do recurso selecionado e um menu de navegação horizontal (Tabs).
- **Se clicar num Node:** Tabs -> [Summary, Disks, Network, Syslog].
- **Se clicar numa VM/CT:** Tabs -> [Summary, Console, Hardware, Snapshots].
- **Se clicar num Storage:** Tabs -> [Summary, Volumes, Replication].

## 3. Refatoração do Roteamento
- **Local:** `ui/src/App.jsx`
- Atualize as rotas para suportar este aninhamento profundo. Exemplo:
  - `/kcp/node/:nodeId/vm/:vmId/summary`
  - `/kcp/node/:nodeId/vm/:vmId/console` (Move o `KcpTerminal` para cá)

## 4. Estética "À Prova de Fogo"
- Use o Tailwind para garantir que a UI ocupe 100% da altura da tela (`h-screen`), com overflow escondido no root, mas com barras de rolagem finas apenas nos painéis de conteúdo.
- Bordas devem ser sutis (`border-gray-800`), e a seleção ativa na árvore deve ter um fundo azul discreto (`bg-kryonix-blue/20 text-kryonix-blue`).

## 5. Validação
- Execute `npm run build --prefix ui` para garantir que o React router e os componentes compilem corretamente.
- Se necessário, limpe o `ui/dist` antigo e mantenha a conformidade com as regras do workspace (sem arquivos `.md` na raiz).
```

## Notas de execução segura

- Esta mudança é estrutural e deve ser feita em fase separada da P2/P3 Storage já implementadas.
- Antes de editar, auditar:
  - `ui/src/App.jsx`
  - `ui/src/layouts/DashboardLayout.jsx`
  - `ui/src/pages/kcp/*`
  - `ui/src/lib/api.js`
  - componentes de terminal/console existentes.
- Preservar compatibilidade com a rota atual `/storage` durante a transição, ou criar redirects explícitos.
- Não misturar com backend storage/replication em um mesmo commit.

## Validação esperada

- `npm run build --prefix repos/kryxd/ui`
- Verificação visual via Vite.
- Limpeza de `ui/dist` após build, se o workspace precisar ficar sem artefato gerado.

## Próximo passo recomendado

Executar como nova missão/branch lógica: primeiro criar `TreeView.jsx` e `ContextLayout.jsx` com dados mockados/derivados das APIs existentes; depois migrar rotas profundas sem quebrar os links atuais do KCP.
