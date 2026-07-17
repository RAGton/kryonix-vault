# kryxd Wiring — Controle de Estado e Telemetria KVE

Data: 2026-07-17
Agente: Aura
Status: READY_FOR_REVIEW

## Objetivo

Conectar a interface premium KVE ao backend `kryxd` em dois pontos operacionais:

1. controle de ciclo de vida de instâncias Incus;
2. telemetria host CPU/RAM consumida por gráficos Recharts.

## Escopo alterado

Repo funcional:

```txt
repos/kryxd
```

Arquivos alterados nesta missão:

```txt
src/api/virt.rs
src/api/system.rs
ui/src/lib/api.js
ui/src/views/PveResourceView.tsx
```

Log canônico:

```txt
repos/kryonix-vault/09-Logs/Kryonix/2026-07-17-kryxd-wiring-state-control.md
```

## Rotas criadas

### PUT /api/v2/virt/instances/:id/state

Arquivo:

```txt
repos/kryxd/src/api/virt.rs
```

Contrato recebido pelo frontend:

```json
{
  "action": "start"
}
```

Ações aceitas:

```txt
start
stop
restart
freeze
```

Segurança:

- usa o extractor `RequireCoreRole`;
- aceita sessão Core/ThinkServer conforme RBAC existente;
- codifica o `id` da instância como um único segmento de URL antes de montar o path Incus;
- não expõe token, cookie ou credencial no frontend.

Encaminhamento para Incus:

```txt
PUT /1.0/instances/<id>/state
```

Via Unix socket:

```txt
INCUS_SOCKET
/var/lib/incus/unix.socket
```

Payload enviado ao Incus:

```json
{
  "action": "start|stop|restart|freeze",
  "timeout": 30
}
```

Resposta do `kryxd`:

```json
{
  "status": "accepted",
  "instance": "<id>",
  "action": "<action>",
  "incus": { }
}
```

O campo `incus` preserva a resposta JSON sanitizada retornada pela API local do Incus.

### GET /api/v2/metrics/host

Arquivo:

```txt
repos/kryxd/src/api/system.rs
```

Contrato retornado:

```json
{
  "sampledAtMs": 0,
  "cpuPercent": 0.0,
  "memory": {
    "totalMb": 0,
    "freeMb": 0,
    "usedMb": 0,
    "usedPercent": 0.0
  },
  "source": "procfs-or-dynamic-mock"
}
```

Implementação:

- lê `/proc/stat` duas vezes com intervalo curto para calcular CPU global;
- lê `/proc/meminfo` para `MemTotal` e `MemAvailable`;
- usa fallback mock dinâmico se `procfs` não estiver disponível;
- não adiciona crate nova;
- não executa comando externo.

## Frontend

### API client

Arquivo:

```txt
repos/kryxd/ui/src/lib/api.js
```

Funções criadas:

```js
changeInstanceState(id, action)
getHostMetrics()
```

`changeInstanceState` usa:

```txt
PUT /api/v2/virt/instances/${encodeURIComponent(id)}/state
```

### Interface premium

Arquivo:

```txt
repos/kryxd/ui/src/views/PveResourceView.tsx
```

Mudanças:

- botões `Start`, `Reboot` e `Shutdown` agora chamam `changeInstanceState`;
- header premium `START/STOP` também chama a API;
- adicionada mensagem inline de sucesso/erro/info;
- adicionado polling de telemetria com `setInterval` a cada 3 segundos;
- gráficos Recharts agora usam `chartData` alimentado por `/api/v2/metrics/host`;
- removido uso de `mockChartData` nessa view.

Fluxo frontend:

```txt
PveResourceView.tsx
  ├─ changeInstanceState(id, action)
  │   └─ PUT /api/v2/virt/instances/:id/state
  └─ getHostMetrics()
      └─ GET /api/v2/metrics/host
```

## Validações executadas

### Vite build

Comando:

```bash
npm run build --prefix repos/kryxd/ui
```

Resultado:

```txt
✓ 2476 modules transformed.
✓ built in 5.99s
```

Warnings conhecidos:

```txt
/img/noise.png referenced in /img/noise.png didn't resolve at build time
Some chunks are larger than 500 kB after minification
```

### Rust check

Comando:

```bash
cargo check --workspace
```

Resultado final:

```txt
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.16s
```

Erro encontrado e resolvido durante a validação:

```txt
E0593: unwrap_or_else esperava closure com argumento de erro
E0689: saturating_sub em inteiro sem tipo inferido
```

Correção:

```rust
.unwrap_or_else(|_| mock_memory_metrics())
let total_mb: u64 = 16_384;
```

### TypeScript TSX direcionado

Como não existe `tsconfig*` no `ui/`, foi executado um check direcionado do arquivo alterado:

```bash
npx --prefix repos/kryxd/ui tsc --noEmit --jsx react-jsx --moduleResolution bundler --module ESNext --target ES2022 --allowSyntheticDefaultImports --esModuleInterop --skipLibCheck --allowJs repos/kryxd/ui/src/views/PveResourceView.tsx
```

Resultado:

```txt
exit 0
```

### Diff check

Comando:

```bash
git -C repos/kryxd diff --check -- src/api/virt.rs src/api/system.rs ui/src/lib/api.js ui/src/views/PveResourceView.tsx
```

Resultado:

```txt
exit 0
```

### Verificação ad-hoc

Script temporário:

```txt
/tmp/nix-shell-266339-3526915383/hermes-verify-*.py
```

Resultado:

```txt
AD-HOC VERIFY KVE WIRING STATE CONTROL: PASS
cleanup ok
```

Cobertura da verificação:

- rota `PUT /api/v2/virt/instances/:id/state` existe;
- rota usa `RequireCoreRole`;
- path Incus `/1.0/instances/<id>/state` é usado;
- ações `start`, `stop`, `restart`, `freeze` estão mapeadas;
- Unix socket Incus com override `INCUS_SOCKET` existe;
- `id` é codificado como path segment;
- rota `GET /api/v2/metrics/host` existe;
- telemetria lê `/proc/stat` e `/proc/meminfo`;
- fallback mock dinâmico existe;
- frontend expõe `changeInstanceState` e `getHostMetrics`;
- botões premium chamam a API;
- polling a cada 3 segundos foi configurado;
- Recharts recebe `chartData` vivo;
- `ui/dist` foi removido após build.

## Cleanup

Após `npm run build`, o artefato gerado foi removido:

```txt
repos/kryxd/ui/dist absent
```

## Diff stat escopado

```txt
src/api/system.rs                | 204 +++++++++++++++++++++++++++++++++++-
src/api/virt.rs                  | 220 +++++++++++++++++++++++++++++++++------
ui/src/lib/api.js                |  84 ++++++++++++---
ui/src/views/PveResourceView.tsx | 198 +++++++++++++++++++++++++++++------
4 files changed, 621 insertions(+), 85 deletions(-)
```

Observação: `ui/src/lib/api.js` e `ui/src/views/PveResourceView.tsx` já carregavam alterações prévias do transplante premium; o stat reflete o diff acumulado desses arquivos na working tree.

## Riscos restantes

1. O endpoint de estado faz mutação real no Incus; deve continuar protegido por sessão Core/ThinkServer.
2. A UI chama o endpoint real; em ambiente sem Incus/socket, a mensagem de erro deve aparecer no painel.
3. A telemetria é host-level, não ainda por VM/CT individual.
4. A integração visual premium existe em `PveResourceView.tsx`; rotas atuais do shell KCP ainda podem usar placeholders em algumas áreas.
5. Nenhum teste E2E contra Incus real foi executado nesta etapa.

## Estado

```txt
READY_FOR_REVIEW
```

Nenhum commit ou push foi executado.
