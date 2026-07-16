# Instruções para IA / Copilot — Projeto RAGOS

Autor: **RAGton — Gabriel Aguiar Rocha**  
Projeto: **RAGOS — Remote Architecture for GNU/Linux Operating Systems**  
Ano: **2026**  
Idioma obrigatório: **Português (pt-BR)**  
Formato obrigatório: **Markdown estruturado**

---

# 1. Objetivo

Este documento define **como a IA ou Copilot devem contribuir com o projeto RAGOS**.

Toda alteração feita pela IA deve priorizar:

# Instruções para IA / Copilot — Projeto RAGOS

**Autor:** RAGton — Gabriel Aguiar Rocha  
**Projeto:** RAGOS — Remote Architecture for GNU/Linux Operating Systems  
**Ano:** 2026  
**Idioma obrigatório:** Português (pt-BR)  
**Formato preferencial:** Markdown técnico, claro e estruturado

---

## 1. Objetivo

Este documento define como agentes de IA devem contribuir com o projeto **RAGOS**.

Toda contribuição deve priorizar, nesta ordem:

1. estabilidade operacional;
2. clareza arquitetural;
3. reprodutibilidade;
4. infraestrutura declarativa;
5. simplicidade de manutenção.

Ao concluir uma alteração, a IA deve conseguir explicar:

- o que mudou;
- por que mudou;
- onde a mudança se encaixa na arquitetura;
- qual impacto operacional existe.

---

## 2. Contexto arquitetural

O RAGOS é uma plataforma diskless baseada em NixOS. A arquitetura parte das seguintes premissas:

- clientes bootam via rede;
- o servidor concentra publicação e persistência;
- o cliente deve permanecer descartável;
- o estado operacional relevante deve ser centralizado;
- a configuração deve ser declarativa.

Tecnologias e áreas envolvidas:

- PXE, iPXE e HTTPBoot parcial;
- NFS para compartilhamento de store e homes;
- NixOS para composição de sistema;
- shell, Rust e React no instalador;
- observabilidade com Prometheus e Grafana.

---

## 3. Estrutura real do repositório

Antes de editar, a IA deve considerar a estrutura atual do projeto:

```text
.
├── flake.nix
├── README.md
├── INSTRUCOES.md
├── docs/
├── flake/
├── installer/
│   ├── installer.nix
│   ├── iso.nix
│   ├── params.nix
│   ├── partitioning.nix
│   ├── ragos-install.sh
│   └── installer-ui/
├── client/
├── server/
├── ragc/
├── themes/
│   ├── fonts/
│   └── plymouth/
└── SRV-RAGOS/
```

Responsabilidades esperadas:

- `flake.nix`: centraliza parâmetros e outputs principais;
- `flake/`: concentra entrypoints e helpers Nix da organização nova;
- `installer/`: define instalação, ISO e bootstrap do servidor;
- `client/`: define o entrypoint canônico do cliente;
- `server/`: define o entrypoint canônico do servidor;
- `ragc/`: define a árvore canônica da CLI;
- `themes/`: concentra fontes, branding e assets de boot;
- `server/pxe/`: concentra os assets iPXE e menus de boot;
- `docs/`: contém a documentação oficial;
- árvores legadas `SRV-RAGOS/` e `ragos/`: não devem ser reintroduzidas.

---

## 4. Regras de arquitetura que não devem ser descaracterizadas

O fluxo operacional base do sistema é:

```text
UEFI
    ↓
PXE
    ↓
BOOTX64.EFI
    ↓
iPXE
    ↓
boot.ipxe
    ↓
kernel + initrd
    ↓
cliente RAGOS
```

Portanto, toda mudança deve preservar:

- servidor como ponto central de publicação;
- cliente como unidade descartável;
- clareza do fluxo de boot;
- compatibilidade com o `ragc` como interface principal de publicação;
- capacidade de diagnóstico simples.

Se a mudança afetar boot, rever também:

- [docs/boot-process.md](../docs/boot-process.md)
- [docs/architecture.md](../docs/architecture.md)
- [docs/troubleshooting.md](../docs/troubleshooting.md)

---

## 5. Padrões de alteração esperados

### 5.1 Preferir mudança mínima

Evitar grandes refatorações sem necessidade direta.

Preferir:

- diffs pequenos;
- preservação do estilo existente;
- ajustes localizados;
- atualização pontual da documentação impactada.

### 5.2 Manter responsabilidade única

Cada módulo, script ou página deve ter foco claro.

Evitar:

- misturar lógica de rede com UI;
- misturar persistência com fluxo de instalação;
- duplicar decisões que já existem em outro componente.

### 5.3 Não tratar runtime como código-fonte

Não propor versionamento de diretórios operacionais como:

```text
/srv/http
/srv/tftp
/srv/data
/srv/nfs
/srv/nix-store
```

Esses caminhos representam estado gerado ou mantido em execução.

---

## 6. Regras sobre parâmetros globais

Os parâmetros centrais do projeto devem permanecer concentrados em:

- [flake.nix](../flake.nix)
- [installer/params.nix](../installer/params.nix)

Diretrizes:

1. evitar hardcode duplicado;
2. reutilizar `specialArgs` sempre que possível;
3. validar novos parâmetros com mensagens claras;
4. manter nomes estáveis quando consumidos por múltiplos módulos.

Ao introduzir um parâmetro global novo, a IA deve:

- definir o valor;
- validar o tipo;
- propagar para o ponto de consumo;
- documentar o efeito.

---

## 7. Regras específicas do cliente

O cliente exposto publicamente fica em [client](../client).

O que deve ser preservado:

- perfil diskless;
- boot por rede;
- modularização do sistema;
- publicação por `ragc`.

Ao alterar o cliente, revisar impacto em:

- [client/client.nix](../client/client.nix);
- [ragc/default.nix](../ragc/default.nix);
- [client/modules](../client/modules);
- [docs/client.md](../docs/client.md).

Evitar tornar o `ragc`:

- obscuro no uso;
- dependente de caminhos mágicos não documentados;
- mais manual do que o necessário.

---

## 8. Regras específicas do servidor

O servidor exposto publicamente fica em [server/server.nix](../server/server.nix).

Ao alterar o servidor, preservar:

- composição declarativa legível;
- separação entre rede, serviços, storage e monitoramento;
- previsibilidade do layout de `/srv`;
- compatibilidade com `nixos-rebuild` e o instalador.

Alterações comuns que exigem documentação:

- serviços expostos;
- portas e firewall;
- layout de storage;
- estratégia de exportação NFS;
- fluxo de monitoramento;
- provisioning de boot.

---

## 9. Regras específicas do instalador

O instalador tem duas camadas principais:

- entrypoint Nix em [installer/installer.nix](../installer/installer.nix);
- shell script em [installer/bin/ragos-install](../installer/bin/ragos-install);
- interface em [installer/installer-ui](../installer/installer-ui).

Ao alterar o instalador:

- manter coerência entre UI e backend;
- preservar o contrato de `params.nix`;
- evitar regressão no fluxo do `nixos-install`;
- manter mensagens de erro úteis;
- registrar novos passos operacionais na documentação.

Se a alteração tocar a UI, priorizar:

- validação de entrada;
- clareza do fluxo;
- consistência visual;
- previsibilidade do estado do wizard.

---

## 10. Regras de documentação

Sempre que possível, a documentação deve responder:

- o que é;
- para que serve;
- onde fica;
- como funciona;
- quais cuidados operacionais existem.

Estrutura sugerida:

```markdown
# Título

## O que é

## Para que serve

## Onde fica no projeto

## Como funciona

## Fluxo, operação ou exemplo

## Impactos e cuidados
```

Diagramas Mermaid devem ser usados quando aumentarem a clareza real do documento.

---

## 11. Segurança e operação

Toda contribuição deve respeitar princípios mínimos de segurança:

- não ampliar exposição de serviços sem necessidade;
- manter escopo claro de DHCP, TFTP, HTTP e NFS;
- não introduzir credenciais em texto plano além do estritamente necessário ao projeto;
- preservar logs e sinais úteis para troubleshooting;
- evitar mudanças que compliquem rollback e diagnóstico.

Se a alteração afetar rede ou acesso remoto, avaliar impacto em:

- firewall;
- SSH;
- DHCP;
- TFTP;
- HTTP;
- NFS.

---

## 12. Quando a IA deve atualizar a documentação

A documentação deve ser atualizada sempre que houver mudança em:

- arquitetura;
- fluxo de boot;
- parâmetros globais;
- comportamento do `ragc`;
- processo de instalação;
- layout do servidor;
- troubleshooting operacional.

---

## 13. Checklist antes de concluir uma tarefa

Antes de encerrar uma contribuição, a IA deve verificar:

1. a arquitetura diskless foi preservada?
2. os parâmetros continuam centralizados?
3. o diff ficou proporcional ao problema?
4. a documentação impactada foi revisada?
5. nomes, caminhos e responsabilidades continuam claros?
6. o operador continua conseguindo diagnosticar e manter o sistema?

---

## 14. Resultado esperado

Toda contribuição de IA deve deixar o projeto mais:

- auditável;
- reproduzível;
- coeso;
- compreensível;
- simples de operar.

Quando houver dúvida entre uma solução mais sofisticada e outra mais previsível, preferir a mais previsível.
O servidor é definido publicamente em [server/server.nix](../server/server.nix) e modularizado em [server/modules](../server/modules).
