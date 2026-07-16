# Contribuindo para o RAGOS

Este repositorio existe para operar uma infraestrutura diskless previsivel. Toda contribuicao deve preservar clareza, fonte de verdade unica e operacao reproduzivel.

## Estrutura do repositorio

- `docs/`: documentacao canonica do estado atual real.
- `docs/archive/`: material historico, forense, experimental ou superado.
- `scripts/ops/`: automacao suportada para operacao e manutencao.
- `scripts/tests/`: harnesses reproduziveis de validacao e regressao.
- `scripts/lab/`: automacao de laboratorio, QEMU, Hyper-V, WSL e experimentos.
- `client/`: perfis e modulos do cliente diskless.
- `server/`: servidor `srv-rag`, servicos e runtime do host.
- `ragc/`: publicacao, promote, rollback, GC e diagnostico das geracoes publicadas.

## Regras para documentacao

- Documento novo vai para `docs/` apenas se descrever o comportamento atual em uso.
- Documento historico, plano encerrado, forensics ou transicao vai para `docs/archive/`.
- Material de apoio pode ficar em `docs/` fora de `archive/` apenas se ainda ajudar engenharia ativa sem virar fonte principal.
- Documentacao canonica deve refletir o estado atual real do repo e da operacao.
- Se um documento nao corresponde mais ao sistema atual, atualize ou mova para `docs/archive/`.
- Todo Markdown em `docs/` e `docs/archive/` deve abrir com `Status` e `Scope`.
- Documento canonico deve incluir `Last reviewed` no topo.

## Regras para scripts

- Script vai para `scripts/ops/` somente se for seguro, suportado, parametrizavel e util no fluxo normal.
- Script vai para `scripts/tests/` quando validar comportamento de forma reproduzivel.
- Script vai para `scripts/lab/` quando depender de ambiente local, VM, serial, WSL, Hyper-V, QEMU ou experimento.
- Script experimental nao fica em `scripts/ops/`.
- Script com caminho pessoal, nome fixo de VM ou topologia local nao e script operacional.
- Todo script novo em `scripts/` deve abrir com `Purpose`, `Category` e `Safety`.
- Use `Expected environment` e `Requires` quando isso evitar uso indevido.

## Regras para mudancas estruturais

- Nao duplique logica entre modulos, scripts e docs.
- Nao crie wrappers mortos, aliases vazios ou arquivos de compatibilidade sem uso real.
- Nao deixe arquivo temporario virar estrutura permanente.
- Nao mantenha duas fontes de verdade para o mesmo comportamento.
- Se uma area foi substituida, remova ou arquive a antiga no mesmo change set.

## Regras para contribuicoes tecnicas

- Valide `nix eval` ou `flake check` antes de propor mudanca.
- Se a arquitetura, operacao ou caminho oficial mudou, atualize a documentacao canonica no mesmo commit.
- Prefira mudanca pequena, clara e com responsabilidade unica.
- Otimize para previsibilidade operacional, nao para conveniencia local.
- Nao trate script de laboratorio como prova de desenho de producao.

## Inventario

- O inventario canonico vive em `/etc/ragos-inventory`.
- Ele nao deve voltar para dentro da geracao do servidor nem para arquivos embutidos no host.
- `dnsmasq.conf` renderizado nao e fonte de verdade; e derivado do inventario.
- Mudanca de inventario deve respeitar o fluxo declarativo e validado de renderizacao/aplicacao.

## Perfis do cliente

- Perfis de cliente sao artefatos publicados.
- A troca de profile acontece no servidor, via publicacao e promote das geracoes.
- Cliente diskless nao deve ser tratado como maquina instalada localmente.
- `hyperv-debug`, `desktop-generic`, `desktop-lab` e `rescue-minimal` existem para finalidades diferentes e nao devem ser misturados.

## Antes de abrir a mudanca

- Verifique se o arquivo novo esta no lugar certo.
- Verifique se nao existe outro arquivo cobrindo a mesma funcao.
- Verifique se a documentacao principal continua correta.
- Verifique se a mudanca reduz ambiguidade em vez de criar mais uma excecao.
