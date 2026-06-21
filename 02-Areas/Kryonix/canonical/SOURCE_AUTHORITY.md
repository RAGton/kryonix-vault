---
status: ativo
validade: validado_por_decisao_humana
tipo: politica
projeto: kryonix
componente: source-authority
fonte_verdade: decisao_humana
confianca: alta
rag: ativo
graph: true
validado_em: 2026-06-19
tags: [kryonix, source-authority, hierarquia, prod-user, kryonixos, post-install]
---

# Kryonix — Source Authority

> Esta nota define a hierarquia de autoridade entre Vault, repositórios DEV, instalação PROD core e configuração PROD-user.
> Trabalha em conjunto com `[[02-Areas/Kryonix/canonical/CURRENT_OPERATION_MODE]]` e `[[02-Areas/Kryonix/canonical/RAG_POLICY_LOCAL]]`.
> Enquanto Glacier estiver congelado, validações sobre ele devem ser `SKIPPED_BY_OPERATION_MODE`.

## Decisão

Por decisão humana (2026-06-19), o modo operacional atual é:

```
Inspiron       = runtime ativo
Hermes local   = agente principal
OpenRouter     = provider/modelos externos
Vault local    = /home/rocha/kryonix/kryonix-vault
Glacier        = congelado para runtime/servicos ate reinstalacao via ISO oficial
```

Esta política aplica-se apenas a este escopo. Nada aqui assume Glacier como runtime.

## Hierarquia de autoridade

Quando houver conflito entre fontes, prevalecem as do topo da lista:

```
 1. Decisão humana atual
 2. Código real do repo DEV: /home/rocha/kryonix/kryonix
 3. Configuração local DEV/user, se existir: /home/rocha/kryonix/kryonixos
 4. Código instalado/PROD core: /etc/kryonix
 5. Configuração instalada/PROD-user: /etc/kryonixos
 6. CURRENT_OPERATION_MODE.md
 7. RAG_POLICY_LOCAL.md
 8. 02-Areas/Kryonix/canonical/**
 9. 02-Areas/Kryonix/systems/**
10. 04-Recursos/skills/**
11. 04-Recursos/prompts/**
12. 04-Recursos/playbooks/**
13. 09-Logs/evidence/**
14. 09-Logs/prs/**
15. 09-Logs/sessions/**
16. 01-MOCs/**
17. 04-Recursos/livros/**
18. cursos/artigos/templates externos
19. 04-Archive/_vaulthub_import_2026-06-20/**  (arquivo morto — subset útil está em 08-Referencias/obsidian/)
20. chats antigos
21. 04-Archive/**
22. duplicatas/lixo/stubs
```

Notas práticas:

- **Nível 1** (decisão humana) só perde para a realidade do código/runtime, não para docs antigas.
- **Nível 3** é paralelo ao **Nível 5** — um para DEV, outro para PROD instalado. Ambos importam o core (Níveis 2 e 4).
- **Níveis 6–15** são o subconjunto do Vault local que tem peso operacional real. Tudo abaixo é contexto auxiliar ou lixo.
- **Níveis 17–22** raramente devem fundamentar decisão operacional.

## Modelo pós-instalação esperado

Três paths canônicos convivem no sistema. Cada um tem papel bem definido.

### `/etc/kryonix`

```
- core do sistema Kryonix
- módulos NixOS
- packages
- features
- profiles
- installer
- CLI kryonix
- fonte técnica principal do sistema
```

Fornece **capacidades disponíveis** (o que existe e pode ser ativado).

### `/etc/kryonixos`

```
- configuração persistente do usuário/host instalado
- escolhas feitas no installer
- features ativadas/desativadas
- perfil do host
- configuração local versionável
- camada que consome o core /etc/kryonix
```

Define **escolhas locais ativadas** (o que está em uso no host específico). É versionável por git e auditável por `kryonix check` / `kryonix test`.

### `/home/rocha/kryonix/kryonix-vault`

```
- memória humana/IA
- conhecimento
- decisões
- logs
- policies
- RAG local
```

Registra **decisões e evidências** em formato humano. Não substitui configuração declarativa — apenas documenta.

## Funcionamento pós-instalação declarativo

A arquitetura alvo do Kryonix pós-instalação oficial é declarativa de ponta a ponta.

### Fluxo desejado

```
ISO oficial Kryonix
  -> installer
  -> detecta hardware
  -> usuário escolhe perfil/features
  -> gera /etc/kryonixos
  -> /etc/kryonixos importa/consome /etc/kryonix
  -> kryonix switch/test/boot aplica estado declarativo
  -> Vault registra decisões, evidências e memória
```

### Princípios

- **Installer grava escolhas em arquivos declarativos**, não em estado oculto (nada de `~/.config` espalhado ou ajustes manuais pós-install sem registro).
- **Features escolhidas no installer** viram opções persistentes em `/etc/kryonixos/hosts/<hostname>/features.nix` e `profiles/selected.nix`.
- **NixOS é a fonte da verdade de estado do sistema**: `kryonix test` valida sem aplicar; `kryonix switch` aplica; `kryonix boot` agenda para o próximo boot.
- **Vault complementa, não substitui**: ele registra decisão e evidência, mas não é fonte de configuração.
- **Pós-instalação auditável por `git diff`, `kryonix check`, `kryonix test`, `kryonix switch/boot`**.

## Estrutura conceitual de `/etc/kryonixos/`

> Esta é a **arquitetura alvo**. Não afirma que já está implementada — é exemplo conceitual de como `/etc/kryonixos` deve parecer quando o installer Kryonix oficial gerar uma instalação limpa.

```
/etc/kryonixos/
├── flake.nix
├── flake.lock
├── hosts/
│   └── <hostname>/
│       ├── default.nix
│       ├── hardware-configuration.nix
│       ├── features.nix
│       ├── users.nix
│       └── state.nix
├── profiles/
│   └── selected.nix
├── home/
│   └── <user>.nix
├── secrets/
│   └── README.md
└── README.md
```

Função de cada peça:

- `flake.nix` — entrada do flake local. Importa `/etc/kryonix` via `path:/etc/kryonix` e define `nixosConfigurations.<hostname>`.
- `flake.lock` — pin das versões (incluindo o pin do core `/etc/kryonix`).
- `hosts/<hostname>/default.nix` — monta o host usando `kryonix.nixosModules.default` + `hardware-configuration.nix` + arquivos específicos.
- `hosts/<hostname>/hardware-configuration.nix` — saída do `nixos-generate-config`, versionada.
- `hosts/<hostname>/features.nix` — liga/desliga features do core (`kryonix.features.ai.enable = true`, etc.).
- `hosts/<hostname>/users.nix` — contas, grupos, papéis.
- `hosts/<hostname>/state.nix` — versão do estado NixOS, serviços de persistência, paths de stateVersion.
- `profiles/selected.nix` — qual perfil Kryonix (`glacier-ai`, `laptop`, `iso`, ...) está ativo.
- `home/<user>.nix` — Home Manager do usuário, consome `kryonix.homeModules.default`.
- `secrets/README.md` — política de segredos (nunca no repo, sempre via `agenix`/`sops-nix`/etc.).
- `README.md` — overview da instalação local.

## Exemplo conceitual de `/etc/kryonixos/flake.nix`

> **Arquitetura alvo, não implementação atual.** Use como referência para o installer Kryonix oficial.

```nix
{
  description = "KryonixOS local host configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    kryonix = {
      url = "path:/etc/kryonix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, kryonix, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        glacier = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            kryonix.nixosModules.default
            ./hosts/glacier/default.nix
          ];
        };
      };
    };
}
```

Pontos chave deste exemplo:

- `kryonix.url = "path:/etc/kryonix"` — referência direta ao core instalado, sem precisar de Cachix fetch em runtime.
- `inputs.nixpkgs.follows = "nixpkgs"` — evita divergência de pin entre core e user-config.
- `kryonix.nixosModules.default` — ponto de entrada oficial do core; traz módulos NixOS + convenções.
- Cada host vira uma entrada em `nixosConfigurations`, montado a partir de `./hosts/<hostname>/default.nix`.

## Regras de autoridade pós-instalação

1. `/etc/kryonix` define capacidades disponíveis.
2. `/etc/kryonixos` define escolhas locais ativadas.
3. `/etc/kryonixos` **nunca** deve copiar o core inteiro; deve importar/consumir `/etc/kryonix`.
4. O installer grava escolhas em arquivos declarativos, não em estado oculto.
5. Features escolhidas no installer devem virar opções persistentes em `/etc/kryonixos`.
6. O Vault registra a decisão e a evidência, mas não substitui a configuração declarativa.
7. Se `/etc/kryonixos` diz que uma feature está ativa, mas `/etc/kryonix` não fornece a feature, isso é **conflito** (ver seção de conflitos).
8. Se o Vault diz que algo foi instalado, mas `/etc/kryonixos` não ativa e o runtime não confirma, **não considerar implementado**.
9. Repo DEV vence para desenvolvimento; `/etc/kryonix` e `/etc/kryonixos` vencem para host instalado.
10. Pós-instalação deve ser auditável por `git diff`, `kryonix check`, `kryonix test` e `kryonix switch/boot`.

## Regra de conflito entre `/etc/kryonix` e `/etc/kryonixos`

```
/etc/kryonix  -> fornece o core
/etc/kryonixos -> ativa escolhas locais

Em conflito:
  - /etc/kryonixos mostra intenção local
  - /etc/kryonix mostra se a capacidade existe
  - runtime/check valida se realmente funciona
```

Procedimento padrão em caso de divergência:

1. **Coletar evidência** dos três lados: `cat /etc/kryonixos/hosts/<host>/features.nix`, `rg` no core `/etc/kryonix`, `kryonix test` no host.
2. **Avaliar intenção vs capacidade**: a feature está escrita em `/etc/kryonixos`? O core tem o módulo correspondente em `/etc/kryonix`?
3. **Validar runtime**: `kryonix check`, `kryonix test`, `systemctl status <service>` no host real (Inspiron localmente; Glacier fica `SKIPPED_BY_OPERATION_MODE`).
4. **Decidir e registrar**:
   - intenção OK + capacidade OK + runtime OK → `validado`
   - intenção OK + capacidade ausente → **conflito**, capability gap no core
   - intenção OK + runtime falha → **conflito**, ativação quebrada
   - intenção ausente + capacidade OK + runtime OK → feature existe mas não está sendo usada
5. **Documentar** em `09-Logs/evidence/` ou `09-Logs/sessions/` com timestamp e referência aos arquivos.

## Fora de escopo temporário

NÃO validar, corrigir, depender ou indexar como verdade operacional:

- `glacier` (host) e qualquer serviço rodando lá enquanto Glacier estiver congelado
- `ssh glacier`
- `ollama.service`, `neo4j.service`, `kryonix-lightrag`, `kryonix-brain-api.service` no Glacier
- LightRAG remoto, MCP remoto via Glacier
- `/var/lib/kryonix` no Glacier
- Storage compartilhado Inspiron↔Glacier
- Path antigo `/home/rocha/.local/share/kryonix/kryonix-vault` (vazio/desalinhado)
- `/etc/kryonixos` ainda não existe no Inspiron (será criado pelo installer oficial)

> Qualquer validação envolvendo Glacier deve ser registrada como `SKIPPED_BY_OPERATION_MODE`, não como PASS nem FAIL.

## Validação extra

Fontes cruzadas para checar esta política contra a realidade atual:

```
ls -la /etc/kryonix                              # core instalado (PROD)
ls -la /etc/kryonixos 2>/dev/null                # config local (deve NAO existir ate installer oficial rodar)
ls -la /home/rocha/kryonix/kryonix               # repo DEV do core
ls -la /home/rocha/kryonix/kryonixos 2>/dev/null # config DEV local (pode existir)
test -d /home/rocha/kryonix/kryonix-vault        # Vault real
git -C /home/rocha/kryonix/kryonix status --short
kryonix check                                    # se CLI disponivel
```

No estado atual (2026-06-19):

- `/etc/kryonix` existe (PROD core ativo).
- `/etc/kryonixos` ainda **não existe** — aguardando installer oficial.
- `/home/rocha/kryonix/kryonix` existe (DEV).
- `/home/rocha/kryonix/kryonixos` **verificado em 2026-06-19** — ver seção `## Estado real detectado em 2026-06-19 — /home/rocha/kryonix/kryonixos` abaixo.

## Estado real detectado em 2026-06-19 — /home/rocha/kryonix/kryonixos

Auditoria **somente leitura** (A12 / A12a / A12b) confirmou o estado deste repo DEV-user.

### Estrutura detectada

```
/home/rocha/kryonix/kryonixos/
├── flake.nix              # kryonix.url = "git+file:///etc/kryonix"
├── flake.lock
├── hosts/
│   ├── inspiron/          # default.nix, disks.nix, hardware-configuration.nix
│   ├── glacier/           # default.nix, bluetooth.nix, disks.nix, hardware-configuration.nix, live.nix, ragenterprise-disko.nix, rve-compat.nix, storage.nix
│   └── inspiron-nina/     # default.nix, disks.nix, hardware-configuration.nix
├── users.nix              # no raiz (nao em hosts/<host>/ — variacao vs modelo)
├── users/
│   ├── shared/dev-workstation.nix
│   └── nina/...
├── docs/{ARCHITECTURE,HOSTS}.md
├── scripts/kryonix-push-cache.sh
├── AGENTS.md, CLAUDE.md, CONTRIBUTING_AGENTS.md, README.md
└── .github/, .claude/, .git/, assets/
```

### Hosts e usuários configurados

| Host | Usuário | Papel declarado |
|---|---|---|
| `inspiron` | rocha | Laptop Intel + iGPU — dia-a-dia / dev / cliente Brain + Hermes |
| `glacier` | rocha | Workstation AMD + NVIDIA — servidor IA headless (congelado) |
| `inspiron-nina` | nina | Laptop Intel + iGPU — máquina da Nina |

`homeConfigurations` no flake.nix:

```
rocha@inspiron       = lib.mkHomeConfiguration "x86_64-linux" "rocha" "inspiron"
rocha@glacier        = lib.mkHomeConfiguration "x86_64-linux" "rocha" "glacier"
nina@inspiron-nina   = lib.mkHomeConfiguration "x86_64-linux" "nina"   "inspiron-nina"
```

### Git

```
branch:           main
remote:           https://github.com/RAGton/Kryonixos.git  (publico)
status --short:   M hosts/glacier/live.nix                  (1 modificado, nao commitado)
ultimos commits:
  2e60720 fix(glacier): resolve conflito bluetooth + pin kryonix com paineis KDE
  8ddd85e chore(repo): reforça .gitignore (secrets/artefatos) — repo público
  6c49545 docs(repo): AGENTS/README/docs + skills (add-host, flake-validate, switch, push-cache)
  2665589 feat(inspiron): VSCode settings declarativos
  80be04e feat(inspiron): ativa tema SDDM Kryonix Aurora
```

### Como consome o core

`flake.nix:17`:

```nix
kryonix.url = "git+file:///etc/kryonix";
```

Implicações:

- O repo DEV-user **consome o core PROD instalado** em `/etc/kryonix`.
- **Não usa GitHub em runtime** (sem dependência de rede).
- **Não usa `/home/rocha/kryonix/kryonix`** (DEV tree) — usa o que está instalado e versionado no PROD.
- `git+file:` usa apenas arquivos **tracked pelo git**; ignora secrets gitignored.
- `path:` é **proibido** pelo próprio flake.nix (linhas 14-16) — leria secrets gitignored e falharia.
- Para DEV puro sem `/etc/kronyix` instalado: `--override-input kryonix git+file:///path/dev`.

### Segurança (.gitignore + busca textual)

`.gitignore` (985 B, 57 linhas) cobre:

- **Env/secrets**: `.env`, `.env.local`, `.env.*`, `brain.env`, `neo4j.env`, `hermes.env`, `kora.env`, `*.secret`, `*.token`
- **Chaves**: `id_ed25519`, `id_ed25519.*`, `id_rsa`, `id_rsa.*`, `*.pem`, `*.p12`
- **MCP/claude**: `.mcp.json`, `.mcp.*.json`, `.mcp.json.bak-*`, `.claude/settings.local.json`
- **Artefatos**: `result`, `result-*`, `iso-result`, `.cache`, `*.log`, `activation.log`, `*.zip`, `*.directory`
- **Editor**: `.direnv/`, `.DS_Store`, `.idea/`, `*.iml`, `*.swp`
- **Build**: `packages/*/target/`

Busca textual por padrões sensíveis (`api_key|token|password|secret|sops|agenix|ssh-ed25519|ssh-rsa|...`):

- **0** arquivos com nome suspeito (`*.env`, `*secret*`, `*token*`, `*password*`, `*private*`, `*.pem`, `*.key`, `id_rsa*`, `id_ed25519*`)
- **39** matches textuais, **nenhum é vazamento real**:
  - 5 em `.gitignore` (esperado)
  - 1 em `flake.nix:15` (comentário explicativo sobre `git+file:`)
  - 2 em `AGENTS.md`/`README.md` (comentários explicativos)
  - 2 chaves SSH **públicas** OpenSSH em `users.nix:12` e `hosts/glacier/rve-compat.nix:112` (baixo risco, são feitas para serem públicas)
  - 7 menções a `CACHIX_AUTH_TOKEN` em `scripts/kryonix-push-cache.sh` (todas como **template/placeholder `***`**)
  - 2 `CLOUDFLARE_*_API_TOKEN_FILE` em `hosts/glacier/rve-compat.nix:81-82` (padrão `*_FILE` — token não commitado, aponta para arquivo externo)
  - 2 `authKeyFile` para `/root/tailscale-authkey.secret` (path externo)
  - 1 comentário sobre design tokens em `hosts/inspiron/default.nix:40` (cores, não secrets)

### Achados de baixo risco (hygiene)

- **Chaves SSH públicas versionadas** em `users.nix:12` e `hosts/glacier/rve-compat.nix:112` — risco baixo, mas idealmente deveriam viver em `authorized_keys` em `/etc/ssh/`, não no repo.
- **`CACHIX_AUTH_TOKEN` apenas como template** em `kryonix-push-cache.sh` — usuário precisa rodar `cachix authtoken <TOKEN>` uma vez.
- **Tokens sensíveis via padrão `*_FILE`** (Cloudflare, Tailscale) — boa prática.
- **Ausência de `sops`/`agenix`** (zero matches) — gestão de secrets pode melhorar.
- **`hosts/glacier/live.nix` modificado localmente** — host congelado, registrar como `SKIPPED_BY_OPERATION_MODE`.

### Classificação

```
repo-dev-user-parcial    # estrutura similar mas nao identica ao modelo /etc/kryonixos
seguro_para_dev          # .gitignore solido, sem vazamento real
```

Variações vs modelo `/etc/kryonixos` definido em `SOURCE_AUTHORITY.md`:

- **Falta** `profiles/` (vazio por design, conforme AGENTS.md linha 36)
- **Falta** `features.nix` por host (provavelmente embutido em `default.nix`)
- **Falta** `state.nix` por host
- `users.nix` está no **raiz**, não em `hosts/<host>/users.nix`
- Tem `disko` em 12 arquivos (não no modelo, mas prática comum)

### O que precisa entrar no futuro installer

O futuro `/etc/kryonixos` (gerado pelo installer oficial Kryonix, ação A11) deve usar este repo como **base**, normalizando:

- Criar `profiles/`, `profiles/selected.nix`
- Criar `features.nix` e `state.nix` por host
- Mover `users.nix` do raiz para `hosts/<host>/users.nix`
- Trocar `git+file:///etc/kryonix` para `path:/etc/kryonix` (canônico do PROD)
- Implementar gestão de secrets via **sops-nix** ou **agenix** (atualmente ausente)
- Mover chaves SSH públicas para `authorized_keys` em `/etc/ssh/` (hygiene)

## Próximas ações seguras

```
A1. Renomear 09-Logs/prs/PR-005 para "Plano - Remote Web Mode" e mover para 03-Projetos/
A2. Mover 04-Archive/_lixo_inbox_2026-06-15/ para 04-Archive/_duplicatas_2026-06-15/
A3. Mover 04-Recursos/templates/vaulthub/ para 04-Archive/external/obsidian-hub/
A4. Anotar/apagar Anthony Gold.md (0 bytes)
A5. Mover summary_compacted_2026-06-18.json para 09-Logs/_meta/
A6. Re-sincronizar 02-Areas/Kryonix/canonical/* e systems/* com /etc/kryonix/docs/
A7. Marcar kryonix-brain-api.service como partial em /etc/kryonix/docs/CURRENT_STATE.md
A8. Aplicar frontmatter padrao nos arquivos ativos
A9. Revisar skill 04-Recursos/skills/revisao-nixos-flake/SKILL.md
A10. Indexar subset "rag: ativo" no Hermes local via OpenRouter
A11. Installer Kryonix oficial -> gerar /etc/kryonixos na primeira instalacao limpa (usar kryonixos como base, normalizar profiles/features/state)
A12c. Decidir sobre M hosts/glacier/live.nix (mudanca local em host congelado -> SKIPPED_BY_OPERATION_MODE)
A12e. Higienizar chaves SSH publicas (mover de users.nix e rve-compat.nix para authorized_keys)
```

Nada disso toca Glacier, `/etc/kryonix` direto, `/var/lib/kryonix`, ou faz commit sem revisão.

---

**Política ativa e validada por decisão humana em 2026-06-19.**
**Reavaliar quando `/etc/kryonixos` for criado pelo installer oficial e quando Glacier for reinstalado com ISO Kryonix.**
**Enquanto Glacier estiver congelado, validações relacionadas devem ser `SKIPPED_BY_OPERATION_MODE`.**
