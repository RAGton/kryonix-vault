---
title: "Playbook - <Nome>"
type: playbook
status: active
tags: [playbook]
trigger: <ex: incidente prod | release | doctor full | onboarding>
duration_estimate: <ex: 15min | 2h | 1 dia>
risk_level: low | medium | high | destructive
created: 2026-06-14
updated: 2026-06-14
---

# Playbook — <Nome>

<context>
  Quando e por que este playbook é executado. Inclui pré-condições e estado
  esperado do sistema antes de começar.
</context>

<task>
  Conduzir <quem> através de <operação> com rollback seguro em caso de falha.
</task>

## Pré-requisitos

- acesso necessário: <ssh | sudo | tailscale | api-key>
- ferramentas: <git, just, nix, etc>
- backups confirmados: sim/não
- janela de manutenção: <sim/não, horário>

<constraints>
  - NUNCA pular o passo de backup
  - NUNCA executar destrutivo sem confirmação humana
  - parar e escalar se passo X retornar exit != 0
</constraints>

## Passos

### 1. Verificação inicial

```bash
# comandos read-only para baseline
```

Checkpoint: o que deve estar verdadeiro antes de prosseguir.

### 2. <Ação principal>

```bash
# comando real
```

Checkpoint: validação após o passo.

### 3. Validação final

```bash
# comandos de verificação
```

## Rollback

Cenário em que algo falha: como reverter passo a passo.

```bash
# comandos de rollback
```

<acceptance>
  - [ ] todos os checkpoints positivos
  - [ ] sem erro em logs
  - [ ] sistema voltou para estado esperado (ou foi corretamente revertido)
</acceptance>

<risks>
  - <risco operacional 1 e mitigação>
  - <risco operacional 2 e mitigação>
</risks>

## Métricas / Observabilidade

O que medir durante e depois da execução.

## Quando NÃO usar este playbook

- cenário fora do escopo 1
- cenário fora do escopo 2

## Links relacionados

- [[../../10-MOCs/Mapa - <Área>]]
- [[../skills/<skill-relacionada>/SKILL]]
