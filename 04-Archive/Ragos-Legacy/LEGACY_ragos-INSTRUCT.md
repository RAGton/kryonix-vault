# INSTRUCT -- Contrato arquitetural e direcao de implementacao do RAGOS

Este documento orienta contribuicao tecnica, revisao arquitetural e automacao assistida por IA no repositorio do RAGOS.

Ele e normativo.

Quando houver conflito entre conveniencia local e este documento, vence este documento ate que a arquitetura seja deliberadamente revista.

---

# 1. Norte arquitetural

O RAGOS e uma plataforma on-premises para clientes diskless reais, com estas propriedades obrigatorias:

- o cliente e tratavel como hardware descartavel;
- o sistema operacional do cliente e centralizado;
- o root do cliente deve convergir para imagem netboot imutavel e compartilhada;
- a persistencia do usuario e centralizada no servidor;
- a operacao deve ser previsivel, auditavel e reproduzivel.

## 1.1 Decisao central atual

### Root do cliente

A direcao oficial do projeto e:

- NixOS netboot;
- imagem SquashFS;
- overlay temporario em RAM.

### Persistencia

A persistencia do endpoint deve ocorrer exclusivamente em:

- `/home` via NFSv4.

### Nao usar como destino final

- iSCSI como root padrao do cliente;
- root stateful individual por maquina;
- dependencia operacional de disco local;
- `/nix/store` remoto por NFS como modelo definitivo de root.

Se algum trecho do codigo ou da documentacao ainda pressupoe `/nix/store` remoto por NFS como modelo final, trate isso como legado em transicao.

---

# 2. Principios obrigatorios

Toda mudanca deve preservar estes principios:

## 2.1 Estabilidade antes de novidade

Nao introduzir complexidade so porque ela parece sofisticada.

## 2.2 Fonte de verdade explicita

Nada de parametro relevante espalhado em varios pontos sem contrato.

## 2.3 Estado operacional separado de codigo-fonte

Runtime, cache, leases, artefatos publicados, snapshots e inventario gerado nao sao codigo.

## 2.4 Cliente stateless

Tudo que puder permanecer fora do endpoint deve permanecer fora do endpoint.

## 2.5 Mudanca auditavel

Toda decisao importante deve deixar rastro em:

- codigo;
- documentacao;
- runbook;
- contrato operacional.

## 2.6 Responsabilidade unica por componente

- `ragos` opera o servidor e a infraestrutura;
- `ragc` opera a imagem do cliente;
- o instalador instala o servidor;
- o cliente nao vira mini-servidor por conveniencia.

---

# 3. Regras arquiteturais nao negociaveis

## 3.1 Split-storage obrigatorio no servidor

O servidor deve manter dois tiers distintos:

### Tier 0 -- sistema do servidor

Contem:

- NixOS do host;
- servicos do host;
- logs e configuracoes locais.

Caracteristicas:

- reinstalavel;
- descartavel;
- sem dados de usuario.

### Tier 1 -- dados persistentes

Contem:

- `/srv/data/home`
- `/srv/data/images`
- `/srv/data/snapshots`

Caracteristicas:

- persistente;
- protegido;
- auditavel;
- suportado por BTRFS.

## 3.2 BTRFS obrigatorio no disco de dados

Subvolumes esperados:

- `@ragos_homes`
- `@ragos_images`
- `@ragos_snapshots`

Politica minima:

- homes com `compress=zstd:3`;
- imagens com `compress=zstd:15`;
- qgroups quando a politica exigir quota.

## 3.3 Cliente diskless real

E proibido desenhar fluxo que dependa de disco local funcional como pre-condicao normal de operacao.

## 3.4 Hostname unico por cliente

Hostname do cliente deve derivar de inventario por:

- MAC;
- reserva DHCP;
- ou ambos.

Nunca usar hostname generico compartilhado.

## 3.5 DHCP / PXE / iPXE corretos

A implementacao de boot deve diferenciar:

- cliente PXE inicial;
- cliente iPXE ja chainloaded;
- arquitetura UEFI x86_64.

## 3.6 Wake-on-LAN e responsabilidade do servidor

Wake-on-LAN:

- pertence ao `ragos`;
- opera por hostname ou MAC inventariado;
- deve ser emitido a partir do servidor RAGOS;
- deve deixar log e saida operacional clara.

E proibido modelar WOL como funcao do `ragc`.

## 3.7 Inventario deve evoluir para fonte unica de verdade

O inventario de clientes deve sustentar:

- reserva DHCP;
- hostname;
- IP;
- MAC allowlist;
- WOL;
- futura UI de gestao.

CSV, lista manual, `dnsmasq` e script com informacoes divergentes significam drift anunciado.

---

# 4. Fronteiras por dominio

## 4.1 `flake.nix` e `flake/`

Responsaveis por:

- composicao do sistema;
- validacao global;
- specialArgs;
- outputs oficiais.

Nao devem virar deposito de logica operacional ad hoc.

## 4.2 `server/`

Responsavel por:

- servicos do servidor;
- rede de boot;
- exports NFS;
- storage;
- observabilidade;
- inventario e operacao do host.

## 4.3 `client/`

Responsavel por:

- imagem do cliente;
- netboot;
- SquashFS;
- desktop e session;
- mounts e integracao do endpoint.

## 4.4 `ragc/`

Responsavel por:

- build da imagem do cliente;
- publicacao;
- rollback;
- retencao;
- validacao da arvore de geracoes.

Nao deve assumir papel de inventario de parque, automacao eletrica ou controle do servidor.

## 4.5 `ragos`

Responsavel por:

- operacao do servidor;
- rebuild do host;
- status;
- diagnostico operacional;
- inventario;
- WOL quando implementado;
- integracao com observabilidade.

## 4.6 `installer/`

Responsavel por:

- instalar o servidor;
- gerar parametros instalados;
- preparar o host para operacao declarativa.

Nao deve carregar logica de operacao diaria do parque.

Nota: os contratos especificos do instalador permanecem documentados em `docs/install-plan-schema.md` e `docs/installer-contract-matrix.md`.

---

# 5. Regras para mudancas arquiteturais

## 5.1 Toda mudanca deve responder quatro perguntas

1. isso move responsabilidade para o lugar certo?
2. isso reduz ou aumenta estado implicito?
3. isso melhora ou piora auditabilidade?
4. isso escala para varias maquinas sem virar artesanato?

Se a resposta for ruim em dois ou mais pontos, revise o desenho.

## 5.2 Mudou fluxo de boot?

Atualize no mesmo PR:

- `README.md`
- `docs/boot-process.md`
- `docs/architecture.md`
- `docs/network.md`
- `docs/runbook.md`

## 5.3 Mudou storage ou persistencia?

Atualize no mesmo PR:

- `README.md`
- `docs/storage.md`
- `docs/server.md`
- `docs/runbook.md`

## 5.4 Mudou CLI ou contrato operacional?

Atualize no mesmo PR:

- `README.md`
- `docs/runbook.md`
- `docs/roadmap.md`
- `INSTRUCT.md` se mudar fronteira ou responsabilidade

## 5.5 Mudou direcao estrategica?

Atualize no mesmo PR:

- `README.md`
- `INSTRUCOES.md`
- `docs/roadmap.md`
- documentos de dominio afetados

---

# 6. Regras especificas para Wake-on-LAN

## 6.1 Objetivo

Permitir que o servidor ligue remotamente um cliente conhecido do parque de forma auditavel e previsivel.

## 6.2 Interface operacional minima esperada

```bash
ragos wol <hostname|mac>
```

Desejavel em seguida:

```bash
ragos clients
ragos wol-all
ragos wait <hostname>
```

## 6.3 Requisitos obrigatorios

A implementacao deve:

- resolver cliente por inventario e nao por chute de IP;
- identificar a interface LAN correta;
- calcular ou receber broadcast de forma controlada;
- enviar magic packet de modo explicito;
- registrar log em journald e saida de CLI;
- falhar com mensagem util quando o cliente nao existir no inventario.

## 6.4 Nao fazer

- nao colocar WOL em `ragc`;
- nao depender de app manual fora do fluxo do servidor;
- nao expor WOL diretamente para WAN;
- nao assumir que VM representa validacao completa de WOL fisico;
- nao esconder lookup de inventario em formato opaco sem contrato.

## 6.5 Criterios de aceite para WOL

Considerar pronto apenas quando houver:

- comando funcional;
- fonte de verdade clara do cliente alvo;
- documentacao atualizada;
- runbook com uso e troubleshooting;
- retorno operacional util ao operador.

---

# 7. Regras para documentacao

Documentacao boa no RAGOS nao e marketing. E contrato.

Cada documento deve responder claramente:

- o que e;
- para que serve;
- o que e obrigatorio;
- o que e legado;
- o que e direcao futura;
- onde aquela responsabilidade comeca e termina.

## 7.1 O que evitar

- frases vagas como "o sistema pode..." sem dizer em que fase;
- misturar estado atual com sonho futuro sem marcar;
- esconder decisao importante em nota de rodape;
- diagramas bonitos porem imprecisos;
- paths, comandos e fluxos sem contexto operacional.

## 7.2 Convencao de honestidade documental

Sempre diferenciar:

- estado atual implementado;
- direcao oficial;
- futuro planejado.

---

# 8. Regras para automacao assistida por IA

Quando IA for usada para sugerir ou aplicar mudancas, ela deve:

1. inspecionar a estrutura real do repositorio antes de propor patch;
2. respeitar as fronteiras entre `ragos`, `ragc`, `server`, `client` e `installer`;
3. nao reintroduzir diretorios legados;
4. atualizar a documentacao impactada;
5. devolver diff por arquivo e comandos de validacao;
6. explicitar o que e implementacao real e o que ficou apenas como direcao.

A IA nao deve:

- inventar paths sem justificar;
- mover logica operacional para o cliente por comodidade;
- criar defaults implicitos escondidos em varios arquivos;
- tratar WOL como detalhe irrelevante;
- manter docs desalinhadas com a arquitetura decidida.

---

# 9. Checklist obrigatorio antes de merge

## Arquitetura

- [ ] A mudanca respeita o contrato atual de root via NFS `/nix/store` + overlay?
- [ ] A persistencia continua restrita ao NFS `/home`?
- [ ] A responsabilidade ficou no componente correto?
- [ ] Nao foi introduzido estado local indevido no cliente?

## Operacao

- [ ] Ha comando e fluxo operacional claros?
- [ ] O runbook foi atualizado?
- [ ] Falhas previsiveis tem mensagem util?

## Documentacao

- [ ] README atualizado
- [ ] INSTRUCT/INSTRUCOES atualizados se necessario
- [ ] documentos de dominio atualizados
- [ ] estado atual e direcao futura devidamente marcados

## Validacao

- [ ] build/check executados
- [ ] fluxo principal validado
- [ ] regressões obvias cobertas

---

# 10. Regra final

No RAGOS, uma boa mudanca nao e so a que funciona.

E a que:

- funciona;
- deixa menos ambiguidade do que antes;
- melhora a operacao real;
- e torna o sistema mais facil de explicar sem improviso.
