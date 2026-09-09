---
title: Perfil Operacional Gabriel
type: area
status: active
tags: [area, perfil, gabriel, aura, hermes, kryonix]
created: 2026-09-08
updated: 2026-09-08
agent: Aura
fonte: USER.md + MEMORY.md (snapshot 2026-09-08)
---

# Perfil Operacional Gabriel

> Documento canônico de referência. Toda decisão de longo prazo de Aura/Codex/Claude no
> ecossistema Kryonix deve considerar este perfil. Última atualização: 2026-09-08.

## 1. Quem é Gabriel

| Campo | Valor |
|---|---|
| Nome | Gabriel AguiarRocha |
| Papel | Meu criador e parceiro de trabalho |
| Local atual | Casa 10.1.1.0/24, MikroTik .254 |
| Acesso remoto | Trabalha em horário comercial, acessa **glacier** |
| Idioma | PT-BR coloquial |

## 2. Carreira (horizonte 3 anos)

| Meta | Valor |
|---|---|
| Janela | **3 anos** (não 5) |
| Mudança | **Chile** 🇰🇱 |
| Cargo-alvo | Sysadmin / DevOps |
| Empresa-desejada | **Sonda S.A.** (multinacional chilena de TI) — confirmar |
| Faixa salarial | > US$ 10k/mês |
| Formação | **Sistemas da Informação** |
| Estado civil | Casar com **Nicoly** |
| Patrimônio | Casa própria + carro |
| Empresa própria futura | **GAR Enterprise** |

## 3. Estilo de trabalho

- PT-BR coloquial, sem teoria, patch cirúrgico.
- Responde em 1 letra: `b` / `c` / `sim` / `n` / `vai` / `faz` / `deixa sem`.
- Bloco pronto pra colar > textão. Tabelas curtas > prosa. Terminar com A/B/C/D.
- Rejeita gambiarra — caminho oficial primeiro; PAM/sshd/sudoers custom só em último recurso marcado.
- "Pesquise" / "demora muito" → parar tentativa-e-erro, web_search real (GitHub issues, community).

## 4. Princípios técnicos

### Sistema bem projetado
1. Simplicidade operacional
2. Organização consistente
3. Manutenção + evolução fáceis
4. Automação > processos manuais
5. Documentação clara

### Filosofia de infraestrutura
**TUDO DECLARATIVO.** Single line. Não negociável.

### Code quality
Código organizado + arquitetura clara + estrutura de pastas consistente + boas abstrações + boa documentação.

### Arquitetura rejeitada de cara
Desorganização + acoplamento excessivo + complexidade desnecessária + ausência de padrões + manutenção difícil + sem escalabilidade.

## 5. Stack e linguagens

### Domínio profundo (alvo)
Rust (foco #1), Nix/NixOS, Flakes, Linux Internals, Bash+Zsh, Next.js, React, Podman, Terraform, Proxmox, redes corporativas, MikroTik, Git/GitOps, VPS/self-hosted, AWS, Azure, IA/LLMs, SOs.

### Linguagens atuais vs. alvos
| Hoje | Quer aprender |
|---|---|
| Rust, Python, Bash | Rust avançado, Next.js, React, arquitetura distribuída, frontend moderno |

### Stack greenfield
**Rust + Tokio + Axum + PostgreSQL + HTTP/SSH + NixOS + Containers + infra declarativa.**

### Rejeições explícitas
Windows como plataforma principal · Java · C++ · toolchain legada · soluções GUI-dependentes.

### Áreas obrigatórias de crescimento
Segurança defensiva + ofensiva · GitOps · Observabilidade · IaC · Linux Internals · Virtualização · Containers · Redes · IA · Arquitetura de sistemas distribuídos.

## 6. Infraestrutura operacional

| Aspecto | Decisão |
|---|---|
| Host crítico #1 | **Glacier** (Proxmox bare metal, concentra tudo) |
| Dependências críticas | Glacier + VM Aura + demais VMs + serviços centrais |
| Downtime aceitável | Até **1h**, ideal = mínimo, manutenção fora do horário |
| Backup (prioridade) | Snapshots semanais incrementais |
| Backup (evolução) | Local + replicação secundária + offsite DR |
| Monitoramento | **Prometheus + Grafana + Uptime Kuma + Alertmanager**, logs centralizados quando crescer |
| Self-hosted vs nuvem | **Self-hosted sempre que possível.** Nuvem só com vantagem clara de custo/disp/integr |
| Sempre locais | LLMs · Memória do Hermes · DBs principais · Infra crítica · Automações · Serviços internos |

## 7. Projetos

| Categoria | Projeto |
|---|---|
| Prioridade absoluta | **GAROS** |
| Legado | **GAROS** |
| "Se manter 1 só" | **GAROS** |
| Geração de renda | **nenhum próprio** (renda vem do trabalho CLT) |
| Pesquisa/aprendizado | GAROS · Hermes · Aura · Kryonix · LLMs locais · infra declarativa NixOS · sistemas autônomos IA |

**Alvo futuro explícito:** transformar parte desses projetos em **produtos ou serviços comercializáveis**.

## 8. Visão Hermes/Aura

| Aspecto | Valor |
|---|---|
| Nome do assistente | **Aura** |
| Inspiração | **JARVIS** (Tony Stark) |
| Função | mistura de **IDE + sistema operacional cognitivo + orquestrador de LLM/agents** |
| Uso | pessoal + profissional |
| Importância | **peça central** do dia a dia — **não é descartável** |

### Roadmap 3 anos (JARVIS-grade)
1. Memória persistente de longo prazo
2. Conhecimento completo da infraestrutura
3. Controle de computers/servers/VMs/services
4. Observar telas e interfaces (visão)
5. Execução autônoma de tarefas complexas (com guardrails)
6. Coordenação de múltiplos agents especializados
7. Planejamento + execução de projetos inteiros
8. Administração proativa de infraestrutura
9. Auxílio em estudos, trabalho e vida pessoal
10. Integração com voz, devices, automações

**Objetivo final:** copiloto digital principal.

## 9. Guardrails de autonomia (REGRA-MÃE)

> "Em caso de dúvida, assumir que a ação requer confirmação humana."

**NUNCA executar sozinho, mesmo que julgue seguro:**

| Categoria | Ações proibidas |
|---|---|
| Destruição de dados | Apagar arquivos, diretórios, bancos |
| Movimentação | Mover / sobrescrever dados importantes |
| Disco | Formatar (mkfs, wipefs, parted) |
| Servidor | Comandos destrutivos em prod |
| Rede | Alterar config crítica sem aprovação |
| Deploy | Push pra produção |
| Git | Commit / push / merge automáticos |
| VMs prod | Criar / remover / modificar |
| Dinheiro | Compras / contratar serviços / gastar $$ |
| Segurança | Alterar config de segurança sem aprovação explícita |

## 10. Vida pessoal

| # | Vida | Status |
|---|---|---|
| **Sono** | Meta: dormir ≤23h, acordar 5h30–5h50 (~7h). **Gap atual:** dorme pós-meia-noite, sabota treinos matinais (corrigir gradual) | em transição |
| **Estudos** | Dia a dia integrado a trabalho/faculdade/projetos; fim de semana **≥4h estudo profundo** (Linux, NixOS, Rust, infra, IA) | contínuo |
| **Hobbies** | Corrida · Academia · Programação · Projetos pessoais · Filmes/séries · Viagens · Família | em desenvolvimento |
| **Financeiro CP** | Reserva + aumentar renda técnica | ativo |
| **Financeiro MP** | Trabalho internacional, migração Chile | alinhado com carreira |
| **Financeiro LP** | Fontes próprias + independência financeira (sem depender só de salário) | alinhado com GAR Enterprise |
| **Sucesso pessoal** | Família estável · Independência financeira · Liberdade geográfica (motorhome, viagens) | horizonte |

## 11. Setup técnico imediato

| Item | Valor |
|---|---|
| VM Aura | hostname `aura`, IP **10.1.1.4/24**, user `rocha`, senha `Rag200520@.` |
| Chave SSH da VM | privada fica no **glacier**, md5 `f2941298af7d2bc38208f7e4feaec200` |
| Regra operacional | scp da chave pro Inspiron toda vez que muda |
| Backend Axum (SeniorSystem/kryxd) | `SERVER_PORT=8081` (porta 8080 = Hermes/Kryonix Control Center) |
| Preflight dev server | `ss -tlnp \| grep :8080` + curl antes de upar |
| Chain multi-repo GAROS | `garos` → `garos-installer` → `control-*`; patch em `gar/` ou `garos-installer/` exige `nix flake update` em `garos/` |
| Reflex de validação | `/tmp/hermes-verify-<topic>-XXXXXX.sh` via `mktemp -t` antes de claimar verde |

## 12. Workflow GAROS — estado atual

| Fase | Status | Bloqueio |
|---|---|---|
| **K-127A0** modelo/ADR-003 | ✅ done | — |
| **K-127A1** Validation Layer (Nix, admissionStatus enum, default=approved) | 🎯 **próximo** | — |
| **K-127B** `gar host` CLI (Nix-only) | bloqueado | por A1 |
| **K-127C** SQL migration | bloqueado | por B |
| **K-127D** REST + RBAC | bloqueado | por C **+** P0 do K-123R² (POST `/api/garos/nodes/{mac}/heartbeat` aceita orphan INSERTs) |
| **K-127E** UI | bloqueado | por D |
| **K-127R** enrollment token ISO Live installer | cross-cutting | — |

Regra: **foundation → features, nunca pular camada**. "Sem validação do schema, qualquer um pode inserir admissionStatus = banana".

## 13. Como Aura/Codex/Claude deve operar

1. **Antes de qualquer coisa**: este arquivo + `AGENTS.md` + `VAULT_INDEX.md`.
2. **Decisões de longo prazo**: passar por este perfil.
3. **Apresentar problemas**: causa provável + evidência + impacto + opções A/B/C/D.
4. **Apresentar soluções**: menor mudança correta + validação + rollback + risco residual.
5. **Incerteza**: declarar `UNKNOWN` / `PARTIAL` explicitamente. Não inventar certeza.
6. **Sugestões de carreira/produto**: alinhar com GAR Enterprise + independência financeira + horizonte Chile/3 anos.
7. **Saúde/rotina**: oferecer ajuda quando o gap atual (sono) atrapalhar treinos — sem sermão.
8. **Stack nova**: preferir Rust + NixOS + declarativo. Nunca propor GUI-dependente se houver alternativa CLI.
9. **Produtos futuros**: ao criar feature em Hermes/Aura/Kryonix, considerar viabilidade comercial.

## 14. Próximas ações

- [ ] Validar se Sonda = Sonda S.A. (multinacional chilena de TI).
- [ ] Rever sono: setup de reminder 22h30 + alarm 5h45? (opcional, Gabriel decide).
- [ ] Plano de estudos semanal no vault (`04-Recursos/playbooks/`).
- [ ] Roadmap GAR Enterprise: que projeto do portfólio atual (Hermes/Aura/Kryonix) virar MVP de produto primeiro?

## Links relacionados

- [[VAULT_INDEX]]
- [[KRYONIX_PROJECT_MEMORY_CURRENT]]
- [[01-MOCs/Mapa - Cerebro Supremo de IA]]
- [[PROMPT_MASTER]]
- USER.md (snapshot canônico em `~/.hermes/memories/USER.md`)
- MEMORY.md (notas operacionais em `~/.hermes/memories/MEMORY.md`)

#perfil-operacional #gabriel #aura #jarvis-grade #tudo-declarativo