# Extração de inteligência do RAGOS para serviços do Kryonix Installer

Data: 2026-07-12
Agente: Codex
Repos afetados:

- `kryxd`
- `ragos-installer` somente leitura

## Objetivo

Preservar os guardrails úteis do instalador RAGOS na nova camada
`src/services/` do Kryonix Installer, acrescentando renderização declarativa
Disko para ZFS e persistência segura de hashes fora do plano e do Git.

## Contexto consultado

- `ragos-installer/lib/disk.sh`
- `ragos-installer/lib/security.sh`
- `ragos-installer/lib/common.sh`
- `ragos-installer/steps/04-storage.sh`
- `ragos-installer/steps/07-install.sh`
- `kryxd/src/disk.rs`
- `kryxd/src/domain/config.rs`
- [[03-Projetos/Kryonix Installer]]
- [[03-Projetos/RAGOS Installer]]

## Mudanças realizadas

- `StoragePlan` recebeu `zfs.userRefquota`, obrigatório quando raiz ou dados
  usam ZFS e rejeitado nos demais casos.
- `DiskValidator` passou a coletar `TYPE`, `SIZE`, `RM`, `RO`, `ROTA` e `TRAN`
  via `lsblk`, além de detectar assinaturas existentes com `blkid -p`.
- `DiskoRenderer` gera layouts `single` e `split` para BTRFS, ext4, XFS e ZFS.
- O caso `split + ZFS` usa raiz não ZFS no disco de sistema e pool `zroot` no
  disco de dados, evitando stripe implícito entre discos.
- O pool ZFS usa `ashift=12`, `cachefile=none`, compressão Zstd e datasets
  `srv-data/{home,images,snapshots,storage}`.
- `refquota` é aplicado somente a `zroot/srv-data/home`.
- `PasswordHasher` usa `mkpasswd -m yescrypt --stdin`; a senha não entra em
  argv, ambiente, plano ou logs.
- `SecretStore` materializa `admin-password.hash` fora do Git, com diretório
  `0700`, arquivo `0600`, temporário exclusivo, `fsync` e rename atômico.
- A ponte de migração seleciona o renderer nativo para ZFS e topologia `split`,
  mantendo apenas `single + BTRFS/ext4` no executor legado.
- Dados BTRFS agora recebem qgroups e limite obrigatório em
  `storage.btrfs.userQgroupLimit`; aliases de um mesmo disco físico são
  rejeitados na topologia `split` por `MAJ:MIN`, WWN ou serial.

## Fase 3 — API v2

- `POST /api/v2/plan` desserializa o contrato estrito, calcula SHA-256 do JSON
  canônico e persiste `plan.json` em
  `/run/kryxd/secrets/<planDigest>/`.
- `PUT /api/v2/secrets` recebe o envelope separado, gera Yescrypt via stdin e
  persiste somente `admin-password.hash`; PPPoE, quando presente, fica em
  arquivo separado. Todos os artefatos usam modo `0600` sob diretórios `0700`.
- `POST /api/v2/dry-run` e o alias `/api/v2/preflight` carregam o plano pelo
  digest, executam `DiskValidator`, renderizam Disko em memória e chamam apenas
  `nix-instantiate --parse --expr`.
- Todas as mutações v2 exigem `X-Kryonix-Installer-Token`; falhas usam envelope
  estruturado e nunca ecoam o token, senha ou hash.
- `manual`, `raid` e `luks2` falham fechado com
  `UNSUPPORTED_STORAGE_CAPABILITY` antes de qualquer inspeção de disco.
- Os endpoints v1 permanecem disponíveis como compatibilidade e não foram
  alterados nesta fase.

## Evidência da engenharia reversa

O RAGOS real não possuía ZFS, Disko, `refquota`, detecção `ROTA` nem limite
mínimo de 10 GiB. O hash antigo usava SHA-512 via `mkpasswd --stdin`. Portanto
ZFS, cotas, classificação SSD/HDD, tamanho mínimo e Yescrypt são melhorias
novas e conscientes, não uma cópia literal dos scripts aposentados.

## Fase 4 — Materialização da árvore Git

- `src/services/target_tree.rs` prepara o staging em
  `/run/kryxd/target/kryonixos`, sem tocar `/mnt`.
- O serviço valida URLs HTTPS sem userinfo, query ou fragmento e configura os
  remotes `core`, `upstream` e `downstream`, com push default e tracking no
  `downstream`.
- Somente `flake.nix`, `disko-config.nix`, `state/install-plan.json` e
  `flake.lock` entram na allowlist do índice; não existe `git add .`.
- `nix flake lock` resolve os inputs remotos `core` e `upstream` antes do
  commit, deixando o lock rastreado.
- Para cumprir a regra de secrets antes do commit, o staging fica sem commit
  até `findmnt --mountpoint /mnt` comprovar um mount exato e gravável. O hash é
  então materializado em
  `/mnt/var/lib/kryonix/installer-secrets/admin-password.hash` com `0600` sob
  diretório `0700`.
- Somente depois do hash final o serviço cria o commit
  `chore(installer): materialize installed system` e clona para
  `/mnt/etc/kryonixos` com `--no-hardlinks`.
- O clone remove o `origin` efêmero de `/run`, reconstrói os três remotes,
  compara o HEAD, exige worktree limpa e revalida a identidade do mount.
- O executor v1 ainda não chama esse serviço; portanto a integração executável
  completa permanece `PARTIAL`.

## Commits e branches

Branch do installer: `refactor/installer-phase1`

- `b37c873 refactor(contract): require zfs user refquota`
- `4ce6248 feat(services): port ragos storage and security intelligence`

## Validações executadas

- `cargo fmt --check`: PASS
- `cargo check --locked`: PASS
- `cargo clippy --all-targets --all-features --locked -- -D warnings`: PASS
- `cargo test --locked`: PASS, 85 testes
- parse do Nix gerado para `split + ZFS`: PASS
- `jq empty schemas/install-plan.schema.json`: PASS
- `git diff --check`: PASS
- scan de secrets: somente identificadores e hash sintético de teste
- MCP `kryonix-test`: UNKNOWN, ferramenta não disponível na sessão
- Disko, ZFS, particionamento e `nixos-install`: não executados

Validação incremental da Fase 3:

- `cargo fmt --check`: PASS
- `cargo check --locked`: PASS
- `cargo clippy --all-targets --all-features --locked -- -D warnings`: PASS
- `cargo test --locked`: PASS, 103 testes
- testes HTTP locais: criação do plano/digest, autenticação obrigatória e erro
  JSON estruturado: PASS
- teste de store: modos `0700/0600`, integridade SHA-256 e rejeição de symlink:
  PASS
- MCP `kryonix-test` (`installer-critical` e `vault`): UNKNOWN, ferramenta não
  disponível na sessão
- Disko, ZFS, particionamento e `nixos-install`: não executados

Validação incremental da Fase 4:

- `cargo fmt --check`: PASS
- `cargo check --locked`: PASS
- `cargo clippy --all-targets --all-features --locked -- -D warnings`: PASS
- `cargo test --locked`: PASS, 109 testes e 2 smokes explícitos ignorados na
  suíte padrão
- smoke real offline de `nix flake lock`: PASS com Nix 2.34.7
- smoke real de `nix flake lock` usando os inputs HTTPS canônicos do plano:
  PASS
- testes Git em diretórios temporários: três remotes, tracking, commit exato,
  lock rastreado, sentinel excluído, HEAD idêntico e secrets fora do Git: PASS
- testes fail-closed: mount ausente, hash ausente, lock falho, URL com userinfo e
  branch maliciosa impedem commit/clone: PASS
- estado do host: `/mnt` não está montado; staging e target reais permaneceram
  ausentes
- Disko, ZFS, particionamento e `nixos-install`: não executados
- MCP `kryonix-test` (`installer-critical` e `vault`): UNKNOWN, ferramenta não
  disponível na sessão

## Pendências

- Ligar `TargetTreeService` ao endpoint `/api/v2/install` e substituir a chamada
  ao `executor/target_tree.rs` legado somente depois de um teste de ordem
  completamente mockado.
- Remover o fluxo v1 que ainda aceita plaintext e grava hash em módulo Nix.
- Definir rollback explícito para falhas posteriores ao commit/clone e para
  limpeza de PPPoE efêmero.
- Validar boot, import do pool, mounts e reboot ZFS em VM descartável.
- ZFS executável permanece `PARTIAL` até essa prova em VM.

## Próximo passo recomendado

Conectar o serviço novo ao orquestrador v2 com a ordem
`preflight -> Disko confirmado -> mount -> target tree -> nixos-install`, usando
adapters mockados para provar que nenhuma etapa pode ser antecipada.

#kryonix #installer #ragos #rust #nixos #disko #zfs #security
