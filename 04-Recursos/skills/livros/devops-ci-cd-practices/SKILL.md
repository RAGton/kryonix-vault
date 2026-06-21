---
title: devops-ci-cd-practices
type: skill
status: ativo_revisao_pendente
purpose: Aplicar práticas de DevOps, CI/CD e orquestração de containers baseadas em Casa do Código, Jez Humble e AWS
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: devops
fonte_verdade: livro (DevOps na Prática, Entrega Contínua, Docker, Kubernetes, Jenkins, Caixa de Ferramentas DevOps)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "DevOps na Prática (Casa do Código), Entrega Contínua (Humble et al), Docker (Casa do Código), Kubernetes (Casa do Código), Jenkins (Casa do Código), Caixa de Ferramentas DevOps"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, devops, ci-cd, docker, kubernetes, books]
---

# devops-ci-cd-practices

## Objetivo

Aplicar princípios de **DevOps cultural** (humble), **pipeline de entrega contínua** (Jez Humble), **containerização** (Docker, K8s) e **automação** (Jenkins, ferramentas gerais) no contexto do Kryonix (installer, ISO build, deploy de features).

## Resumo

Consolida 6 obras. DevOps na Prática (CdC) dá a visão geral com exemplos práticos BR; Entrega Contínua (Humble et al.) é o canônico de pipelines; Docker e K8s (CdC) dão a base de containers; Jenkins (CdC) dá automação; Caixa de Ferramentas (CdC) consolida o sysadmin moderno.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao projetar pipeline de build do installer/ISO do Kryonix.
- Ao decidir entre deploy manual, semi-automatizado ou automatizado.
- Ao escrever Dockerfile para serviço do Kryonix.
- Ao estruturar manifestos Kubernetes para deployment futuro.
- Ao configurar job de CI (GitHub Actions, Jenkins).

## Quando não usar

- Não serve para configuração NixOS (usar `revisao-nixos-flake`).
- Não serve para gerenciamento de secrets (usar `auditoria-secrets`).

## Princípios-chave consolidados

### Humble (Entrega Contínua)

1. **Build once, deploy many** — artefato único passa por ambientes.
2. **Deploy != release** — deploy é técnica; release é decisão de negócio.
3. **Automação > documentação** — se pode ser automatizado, deve ser.
4. **Pipeline como código** — versionado, revisado, testado.
5. **Fail fast, recover fast** — build quebrado é prioridade #1.
6. **Zero downtime** — blue-green, canary, rolling updates.
7. **Configuration as code** — infra = código.

### DevOps na Prática (CdC)

1. **Cultura > tools** — DevOps é mudança de mentalidade, não só Ansible.
2. **3 caminhos de DevOps** (Gene Kim):
   - Flow (esq→dir: dev→ops→client)
   - Feedback (dir→esq: ops→dev, rápido)
   - Continuous learning (falhar com segurança)
3. **Time único** — dev e ops compartilham métricas.
4. **Everything as code** — infra, config, test, doc.

### Docker (CdC)

1. **Imagem = snapshot** da aplicação + dependências.
2. **Container ≠ VM** — compartilha kernel, isolamento via namespaces/cgroups.
3. **Dockerfile = receita** — cada instrução é layer cacheável.
4. **Multi-stage builds** — builder separado de runtime.
5. **Volumes** = persistência fora da imagem.
6. **Docker Compose** = definição de serviço multi-container.

### Kubernetes (CdC)

1. **Declarative > imperative** — descrever estado desejado.
2. **Pods** = menor unidade (1+ containers).
3. **Deployments** = rollout com rollback automático.
4. **Services** = descubra e balanceie entre pods.
5. **Ingress** = HTTP routing externo.
6. **ConfigMaps/Secrets** = configuração externa.
7. **Namespaces** = isolamento multi-tenant.

### Jenkins (CdC)

1. **Pipeline as code** (Jenkinsfile) > UI.
2. **Stages** paralelos aceleram pipeline.
3. **Shared libraries** reutilizam lógica entre jobs.
4. **Credentials** nunca em texto — vault.

### Caixa de Ferramentas (CdC)

1. **Linux base** — systemd, journalctl, namespaces, cgroups.
2. **IaC** — Terraform, CloudFormation, Ansible, Puppet.
3. **Monitoramento** — Prometheus, Grafana, ELK, Loki.
4. **Observabilidade** — métricas, logs, tracing.

## Procedimento — projetar pipeline de CI/CD

```txt
1. Mapear estágios:
   [checkout] → [build] → [test] → [package] → [stage] → [deploy]

2. Definir gatilhos:
   - push em branch principal → full pipeline
   - PR → build + test (sem deploy)
   - tag → release artifacts

3. Ambiente como estado:
   - dev, staging, production separados
   - cada stage valida artefato antes de avançar

4. Estratégias de release:
   - Rolling (pods substituem gradualmente)
   - Blue-green (dois ambientes iguais, trocar apontamento)
   - Canary (5%→25%→50%→100%)

5. Rollback como requisito:
   - artefato versionado (nunca sobrescreve tag)
   - migration reversível (down migration)
   - script de rollback testado
```

## Checklist — qualidade de pipeline

```txt
- [ ] Build <10 min (ou dividido em jobs paralelos)?
- [ ] Testes rodam no CI (não só local)?
- [ ] Artefato versionado por commit SHAs?
- [ ] Variáveis sensíveis em vault/secret manager?
- [ ] Pipeline reproduzível (mesmo commit = mesmo artefato)?
- [ ] Deploy reversível em <5 min?
- [ ] Healthcheck em todos os ambientes?
- [ ] Métricas de pipeline: lead time, deploy freq, MTTR, change fail rate (DORA)?
```

## Aplicação no Kryonix

```txt
Pipeline alvo para ISO oficial:
  [checkout kryonix + kryonix-installer]
  → [nix flake check]
  → [nix build .#iso]
  → [teste em VM (qemu)] 
  → [upload para cachix / GitHub release]
  → [notificar canal]
```

## Riscos

- Kubernetes para projeto solo = overengineering.
- CI com testes longos (>1h) ninguém espera.
- Deploy automatizado sem rollback testado = loteria.
- "DevOps sem cultura": só trocou o nome do time de ops.

## Token-saving mechanism

Consolida 6 livros (~1500 páginas) em princípios + 1 procedimento + 1 checklist. Uso: ao projetar pipeline.

## Base prompt

```txt
Atue como engenheiro DevOps sênior.
Dado o contexto do projeto abaixo, aplique a skill [[04-Recursos/skills/livros/devops-ci-cd-practices/SKILL]].
Produza: (1) desenho de pipeline, (2) Dockerfiles/manifestos relevantes,
(3) estratégia de release + rollback, (4) métricas DORA.
```

## Livros-fonte

```txt
04-Recursos/livros/DevOps na Prática - Entrega de Software Confiável e Automatizada - Autor (Casa do Código).pdf
04-Recursos/livros/Entrega Contínua - Como Entregar Software de Forma Rápida e Confiável - Auto (Jez Humble).pdf
04-Recursos/livros/Containers with Docker - Do desenvolvimento à produção - Autor (Casa do Código).pdf
04-Recursos/livros/Kubernetes - Tudo sobre orquestração de contêineres - Autor (Casa do Código).pdf
04-Recursos/livros/Jenkins - Automatize Tudo sem Complicações - Autor (Casa do Código).pdf
04-Recursos/livros/Caixa de Ferramentas DevOps - Um Guia para Construção, Administração e Arquitetura de Sistemas Modernos - Autor (Casa do Código).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/test-driven-development/SKILL]]
- [[04-Recursos/skills/livros/git-github-operacional/SKILL]]
- [[04-Recursos/skills/revisao-nixos-flake/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
