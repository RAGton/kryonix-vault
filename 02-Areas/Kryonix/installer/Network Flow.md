---
type: installer-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, network, nmcli]
links:
  - "[[MOC - Installer]]"
  - "[[Backend Routes]]"
---

# Network Flow — Installer

## Stack

- Frontend Vite: passo Network (`pages/Network.jsx`).
- Helpers puros: `ui/src/utils/network.js` (PR #70).
- API client: `installerApi.applyNetwork()` em
  `ui/src/utils/installerApi.js` → POST `/network/apply`.
- Backend Rust: `src/network.rs` → wrapper sobre `nmcli`.

## Modos

- `dhcp` — interface fica aguardando atribuição via NetworkManager.
- `static` — exige IP, prefix (1..32), gateway IPv4, DNS list.

## Validação (PR #72)

`validate_apply_network_request(req)` retorna `Err((code, msg))`:

- `INTERFACE_EMPTY`
- `INVALID_MODE`
- `MISSING_ADDRESS` / `INVALID_PREFIX` / `MISSING_GATEWAY` / `INVALID_IPV4`
- `INVALID_DNS` (entries não-vazios mal formatados)

## Comportamento UI (PR #70)

- Botão "Avançar" do passo Network chama `handleNetworkNext` que
  invoca `applyNetwork` antes de `goNext`.
- Função `netmaskToPrefix` refatorada para fora do componente (testável).
- Welcome banner / kiosk identifica que IP do servidor já está em
  `wizard.serverIp` (escrito por `detectIp`).

## Comando de debug histórico

`test_nmcli.sh` (preservado em PR #65):

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  kryonix@<ip> "nmcli -t -f NAME,TYPE,DEVICE,IP4.ADDRESS connection show --active"
```


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]