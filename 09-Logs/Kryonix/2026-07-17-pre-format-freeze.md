# Kryonix / KVE — Pre-format Freeze

Data: 2026-07-17
Status: READY_FOR_REVIEW
Escopo: `kryxd` + KVE premium UI + roadmap de autenticação

## Objetivo

Congelar o estado de desenvolvimento antes de pausar a frente KVE e voltar o foco para finalização do Installer.

Este freeze preserva:

- daemon Rust/Axum renomeado canonicamente para `kryxd`;
- frontend KVE premium transplantado do AI Studio;
- rotas e guardas do Installer/Wizard ainda preservados no `App.jsx` oficial;
- Auth Gateway dev atual;
- integração inicial com Incus/cluster/tree/create VM-CT;
- logs técnicos das fases KVE realizadas.

## Decisão crítica: enxerto seguro, não transplante destrutivo

Foi rejeitada a estratégia de apagar `repos/kryxd/ui/src/` ou substituir `App.jsx`/`main.jsx` pelo export cru do AI Studio.

Motivo: o `App.jsx` oficial contém bootstrap e contratos operacionais que não existem no export visual puro:

- `/api/v1/system/identity`;
- fallback controlado para `WizardInstaller`;
- guardas de sessão;
- integração com `POST /api/v1/auth/login` e `GET /api/v1/auth/session`;
- rotas `/kcp/*`;
- preservação do fluxo do Installer.

A abordagem correta é grafting/integração cirúrgica: importar componentes visuais premium sem amputar contratos do backend e do Installer.

## Estado atual da autenticação

O login local real do sistema operacional ainda NÃO está implementado.

O backend atual usa um Auth Gateway dev com:

- usuários permitidos em fase dev, como `admin`, `gabriel` e `root`;
- senha definida por `KRYONIX_AUTH_PASSWORD` quando presente;
- fallback DEV explícito quando `KRYONIX_AUTH_PASSWORD` está definido e `/etc/kryonix/identity.json` ainda não existe;
- sessão via cookie `kryonix_session` com atributos `HttpOnly` e `SameSite=Strict`;
- suporte a Bearer token para clientes API.

Evidência de auditoria sem expor segredo:

```txt
has_password_env=True
has_dev_identity_fallback=True
has_session_cookie=True
has_pam_dependency=False
reads_shadow=False
```

Conclusão: usuário local `rocha` + senha real do sistema ainda não autenticam no KVE. Isso exige fase dedicada.

## Roadmap: Auth System real

Próxima fase recomendada para autenticação:

1. Avaliar integração com Linux PAM no Rust.
2. Preferir PAM em vez de ler `/etc/shadow` diretamente.
3. Manter o backend como único ponto autorizado de autenticação; o frontend nunca deve receber ou persistir senha/token sensível.
4. Definir política de roles:
   - usuário Linux local autorizado;
   - mapeamento de grupos Linux para roles KVE (`Core`, `Operator`, `Viewer`, etc.);
   - fallback dev somente em builds/dev sessions explicitamente configuradas.
5. Documentar e testar permissões necessárias para PAM no ambiente NixOS/serviço systemd.

## Roadmap: Dynamic Login UI

A tela de login deve deixar de apresentar escopos fixos e passar a refletir capabilities reais do host.

Contrato futuro recomendado em `/api/v1/system/identity`:

```json
{
  "hostname": "inspiron",
  "role": "Core",
  "edition": "dev",
  "capabilities": ["desktop", "kve", "node", "installer"]
}
```

Regra de UI:

- se `desktop` não existir em `capabilities`, não mostrar opção Desktop;
- se `kve` não existir, não mostrar KVE;
- se `node` não existir, não mostrar Node Server;
- se o host for Installer/Live ISO, mostrar apenas fluxo compatível com Installer;
- capability vem do estado declarativo NixOS, não de hardcode visual.

## Estado visual KVE

A rota pós-login não deve cair em placeholder `KVE Context / Datacenter Summary`.

Correção aplicada no repo `kryxd`:

- `/kcp/datacenter/summary` usa o dashboard premium real (`DashboardView`);
- summary de node/VM/CT usa `PveResourceView`;
- arquivos auxiliares do dashboard premium foram adicionados:
  - `ui/src/defaultDashboardLayout.ts`;
  - `ui/src/widgetRegistry.tsx`.

## Validações realizadas nesta fase

Validações executadas antes do freeze:

```txt
npm run build --prefix repos/kryxd/ui
cargo check --workspace
```

Resultados observados:

- build Vite passou;
- `cargo check --workspace` passou;
- warnings conhecidos do frontend continuam:
  - `/img/noise.png` não resolvido em build time;
  - chunk JS maior que 500 kB.

## Pendências após o freeze

- Implementar PAM/auth real para usuário local `rocha`/Linux.
- Tornar login dinâmico por capabilities declarativas vindas de NixOS.
- Finalizar integração visual completa sem remover Wizard/IdentityGuard.
- Voltar foco para finalização do Installer e testes E2E.
- Resolver dívida técnica conhecida de testes globais do backend antes de declarar suite green.

## Observações de segurança

- Nenhuma senha real foi registrada neste log.
- Tokens e segredos devem continuar redigidos como `[REDACTED]`.
- Não usar `git add .` no freeze; stagear paths explícitos.
- Não apagar `/tmp/kve-ui-export/` antes de confirmar push remoto e integridade do backup.
