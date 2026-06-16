---
title: Kryonix Architecture - Overview
type: architecture
status: in-progress
tags: [kryonix, architecture, system-design, mTLS, decoupling]
project: kryonix
created: 2026-06-15
updated: 2026-06-15
---

# Kryonix Architecture - Overview

<role>
Atuando como Arquiteto Sênior para definir a topologia e os fluxos de integração entre os 10 subsistemas do ecossistema Kryonix.
</role>

## Resumo
Esta nota descreve a arquitetura distribuída do Kryonix, focando em como os subsistemas interagem utilizando o `[[02-Areas/Kryonix/canonical/Kryonix Entity Schema]]` como contrato de verdade.

## Conexões Estratégicas
- **Hub Central:** [[01-MOCs/Mapa - Kryonix]]
- **Contrato de Dados:** [[02-Areas/Kryonix/canonical/Kryonix Entity Schema]]
- **Implementação Físicas:** [[02-Areas/Kryonix/hosts/Kryonix Host Inventory]]

---

<facts>
- A comunicação entre o `ai-brain` e os `hosts` é baseada em Pull-model via mTLS.
- O estado desejado (Desired State) é definido de forma declarativa via NixOS Flakes.
- O `canonical-schema` é a única fonte de verdade para serialização de eventos.
</facts>

## Ciclo de Vida da Operação (TOON)

```toon
fase,               descrição,                                  subsistema_líder
provisionamento,    boot via PXE/ISO e escrita via disko,      installer
identidade,         geração de chaves e registro no brain,     hosts / ai-brain
configuração,       aplicação de nix-flakes e systemd units,   systems / canonical
observabilidade,    coleta de métricas e logs via vetores,     operations
evolução,           atualização de firmware e software,        ai-brain / systems
```

## Topologia de Integração

A arquitetura é dividida em três camadas principais:

1. **Camada de Orquestração (Control Plane):**
   - **ai-brain:** Coordena decisões e gerencia o repositório de estados.
   - **kryonix-meta:** Contém as políticas globais e o Roadmap.

2. **Camada de Serviço (Data Plane):**
   - **systems / architecture:** Define os templates de serviço e o hardening.
   - **canonical:** Garante a validade das mensagens trafegadas.

3. **Camada de Execução (Edge/Node):**
   - **hosts / installer:** Onde o hardware encontra o código.
   - **branding:** Define a interface de interação humana (CLI/Web).

<best_practices>
- **Stateless by Design:** Nodes de borda não devem armazenar estado crítico local sem replicação.
- **Fail-Fast Registration:** Se um host não valida contra o `Entity Schema`, ele deve ser isolado imediatamente.
- **Audit-Log Everywhere:** Toda mudança de estado iniciada pelo `ai-brain` deve gerar uma `Issue` (Entity: Issue).
</best_practices>

<opinion>
Devemos evitar o uso de SSH direto para orquestração. O modelo "Agent-based Pull" (onde o host consulta o Brain) é mais resiliente a falhas de rede e facilita o gerenciamento de frotas atrás de NAT/Firewalls complexos.
</opinion>

<risks>
- **Single Point of Failure:** O `ai-brain` precisa de alta disponibilidade geográfica para não paralisar o provisionamento.
- **Drift de Esquema:** Mudanças no `canonical` sem retrocompatibilidade podem "brickar" instâncias antigas do `installer`.
</risks>

---

## Procedimento de Validação
- [ ] Executar teste de integração: Criar uma entidade `Host` fake e verificar se o `ai-brain` a processa corretamente.
- [ ] Validar fluxo de `Command`: Enviar um comando via schema e verificar se o `systems` o interpreta.

## Próxima ação
- [ ] Detalhar o fluxo de mTLS no subsistema `operations`.
- [ ] Vincular diagramas Mermaid para cada fase do ciclo de vida.