# Instrucoes do projeto RAGOS

Este documento consolida a visao institucional, a direcao tecnica e os limites do projeto RAGOS.

Ele nao substitui a documentacao de dominio.

Ele define o posicionamento oficial do projeto.

---

# 1. O que e o RAGOS

O RAGOS e uma arquitetura on-premises para estacoes Linux diskless, baseada em NixOS, com foco em centralizacao de sistema, persistencia controlada e operacao previsivel.

A proposta e simples:

- o cliente fisico e descartavel do ponto de vista operacional;
- o sistema do cliente e centralizado;
- o estado relevante do usuario e preservado no servidor;
- a substituicao de hardware nao deve significar reinstalacao manual;
- a operacao deve ser reproduzivel por configuracao.

---

# 2. Identidade do projeto

## 2.1 Natureza

O RAGOS e um projeto de arquitetura e produto tecnico.

Ele nao e apenas:

- um conjunto de scripts;
- um laboratorio de PXE;
- uma ISO personalizada;
- um desktop Linux empacotado.

Ele e um modelo operacional completo para endpoints diskless sob gestao central.

## 2.2 Premissa central

No RAGOS, o endpoint nao e o centro do sistema.

O centro do sistema e o servidor.

---

# 3. Direcao oficial atual

## 3.1 Boot do cliente

Contrato oficial deste ciclo:

- PXE em UEFI;
- chainload para iPXE;
- kernel + initrd servidos via HTTP;
- `/nix/store` remoto via NFS (ro) + overlay tmpfs (rw).

Roadmap declarado:

- migrar root do cliente para netboot/SquashFS quando o pipeline estiver completo e testado ponta a ponta.

## 3.2 Persistencia do usuario

A persistencia do cliente deve ficar em:

- `/home` via NFSv4.

## 3.3 Estado local no cliente

O estado local do cliente deve ser:

- minimo;
- descartavel;
- temporario;
- preferencialmente restrito a overlay em RAM.

## 3.4 Storage do servidor

O servidor deve adotar:

- separacao entre disco de sistema e disco de dados;
- BTRFS no disco de dados;
- snapshots e retencao auditaveis.

## 3.5 Operacao do parque

A operacao do parque deve evoluir para incluir:

- inventario confiavel por cliente;
- hostname unico por MAC/IP;
- controle de boot por allowlist;
- Wake-on-LAN a partir do servidor;
- observabilidade por cliente e por geracao.

---

# 4. O que o projeto valoriza

O RAGOS valoriza:

- previsibilidade;
- auditabilidade;
- simplicidade operacional;
- recuperacao rapida;
- coerencia entre documentacao e implementacao;
- separacao clara de responsabilidades.

Na pratica, isso significa preferir:

- contrato explicito em vez de jeitinho;
- rebuild reproduzivel em vez de ajuste manual;
- inventario em vez de memoria humana;
- rollback claro em vez de heroismo de madrugada.

---

# 5. O que o projeto evita

O RAGOS evita deliberadamente:

- dependencia de estado local no cliente;
- arquitetura inchada de VDI quando endpoint diskless resolve;
- decisoes dificeis de auditar;
- duplicacao de fonte de verdade;
- glamour tecnico sem retorno operacional.

Tambem nao e objetivo principal do projeto:

- competir com plataformas de virtualizacao generalistas;
- virar distribuicao Linux pra tudo;
- priorizar complexidade antes de estabilidade.

---

# 6. Papel do servidor e do cliente

## 6.1 Servidor

O servidor RAGOS deve concentrar:

- DHCP / PXE / iPXE;
- HTTP de boot;
- imagens publicadas do cliente;
- storage persistente;
- `/home` via NFSv4;
- snapshots;
- inventario;
- observabilidade;
- automacao operacional.

## 6.2 Cliente

O cliente deve ser:

- leve em estado local;
- previsivel;
- substituivel;
- dependente do servidor para sistema e persistencia.

Essa assimetria e intencional e saudavel para o modelo do projeto.

---

# 7. Wake-on-LAN como etapa de maturidade

Wake-on-LAN faz parte da direcao correta do RAGOS porque fecha uma lacuna operacional importante:

- o servidor publica a imagem;
- preserva o estado do usuario;
- e tambem deve poder ligar o endpoint remoto quando necessario.

Direcao oficial para WOL:

- operar pelo `ragos`;
- identificar cliente por hostname e MAC inventariado;
- emitir a partir do servidor RAGOS;
- documentar em runbook e roadmap;
- tratar como capacidade de infraestrutura.

Importante: enquanto o comando nao existir no codigo, WOL continua sendo direcao oficial e nao funcionalidade implementada.

---

# 8. Estado atual versus direcao futura

Para evitar documentacao traiçoeira, o projeto sempre deve diferenciar:

## Estado atual implementado

Aquilo que ja existe e pode ser operado hoje.

## Direcao oficial

Aquilo que foi decidido como rumo correto e deve orientar patch, refatoracao e documentacao.

## Futuro planejado

Aquilo que ainda depende de implementacao posterior.

Misturar esses tres niveis produz documento bonito e operacionalmente perigoso.

Decisao valida agora:

- estado atual e oficial: NFS `/nix/store` + overlay;
- futuro planejado: netboot/SquashFS;
- proibido tratar roadmap como se fosse estado atual.

---

# 9. Organizacao da documentacao

O conjunto documental do projeto cumpre estes papeis:

- `README.md` -- visao executiva e mapa do projeto
- `INSTRUCT.md` -- contrato tecnico e regras de implementacao
- `INSTRUCOES.md` -- visao institucional e direcao oficial
- `docs/architecture.md` -- arquitetura do sistema
- `docs/boot-process.md` -- cadeia de boot ponta a ponta
- `docs/storage.md` -- storage, subvolumes, retencao e snapshots
- `docs/network.md` -- rede, DHCP, PXE, iPXE e topologia
- `docs/server.md` -- modulos e servicos do servidor
- `docs/client.md` -- imagem do cliente e comportamento do endpoint
- `docs/runbook.md` -- operacao pratica
- `docs/roadmap.md` -- maturidade e proximos marcos

Mudanca estrutural importante deve atualizar o documento correspondente.

---

# 10. Autoria

Gabriel Aguiar Rocha (RAGton)
