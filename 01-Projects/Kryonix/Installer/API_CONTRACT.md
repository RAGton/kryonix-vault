# Kryonix Installer API Contract

Este documento descreve o contrato de API formalizado entre o Web Kiosk (React/Vite) e o Backend Executor (Rust/Axum).

## Convenções Gerais

- O backend opera exclusivamente na porta `8080`.
- O payload Content-Type padrão é `application/json`.
- A API retorna status codes HTTP adequados (ex: `200 OK`, `401 Unauthorized`, `422 Unprocessable Entity`).
- Toda ação destrutiva requer validação CSRF/Token via Header `X-Kryonix-Installer-Token`.

## Modelo de Erro Estruturado

Qualquer erro de domínio (ex: payload inválido, falha de pré-requisitos) retorna um JSON estruturado com status `422 Unprocessable Entity` ou `400 Bad Request`:

```json
{
  "ok": false,
  "code": "ERROR_CODE",
  "message": "Mensagem amigável para exibição",
  "action": "O que o usuário ou frontend deve fazer a respeito",
  "details": {
    "field": "nome_do_campo_se_aplicavel",
    "received": "valor_recebido",
    "accepted": ["valor_valido1", "valor_valido2"]
  },
  "recoverable": true,
  "destructiveActionStarted": false,
  "sessionId": "uuid-da-sessao"
}
```

## Endpoints de Instalação e Particionamento

### `POST /dry-run`

Valida semanticamente o plano e executa `disko --mode dry-run`.

**Request:**
`InstallPlan` payload (ver schema).

**Response (Sucesso):**
```json
{
  "ok": true,
  "checks": [
    { "ok": true, "message": "Disko dry-run concluído com sucesso" }
  ]
}
```

**Response (Erro - Modo de Disco Inválido):**
```json
{
  "ok": false,
  "code": "INVALID_DISK_MODE",
  "message": "Modo de disco inválido.",
  "action": "Selecione um modo de particionamento válido antes de continuar.",
  "details": {
    "field": "disk.mode",
    "received": "modo_invalido",
    "accepted": ["destroy", "format", "mount", "destroy,format,mount", "format,mount"]
  },
  "recoverable": true,
  "destructiveActionStarted": false,
  "sessionId": "..."
}
```

### `GET /api/token`

**Proteção:** Loopback only (`127.0.0.1` / `localhost`).
**Retorna:** O token da sessão atual que precisa ser fornecido no Header.

## Eventos e Estados Globais

### Estados previstos

```text
BOOTED
UI_READY
PLAN_DRAFT
PLAN_VALIDATING
PLAN_VALID
PLAN_INVALID
DRY_RUN_RUNNING
DRY_RUN_FAILED
DRY_RUN_PASSED
INSTALL_READY
INSTALL_RUNNING
INSTALL_FAILED
INSTALL_SUCCESS
REBOOT_REQUIRED
```

O Frontend deve reagir a esses estados e bloquear navegações prematuras, consumindo `GET /install/status` ou stream SSE para manter sincronia sem heurística solta.
