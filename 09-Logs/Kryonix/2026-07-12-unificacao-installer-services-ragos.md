# Extração de inteligência do RAGOS para serviços do Kryonix Installer

Data: 2026-07-12
Agente: Codex
Repos afetados:

- `kryonix-installer`
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
- `kryonix-installer/src/disk.rs`
- `kryonix-installer/src/domain/config.rs`
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

## Evidência da engenharia reversa

O RAGOS real não possuía ZFS, Disko, `refquota`, detecção `ROTA` nem limite
mínimo de 10 GiB. O hash antigo usava SHA-512 via `mkpasswd --stdin`. Portanto
ZFS, cotas, classificação SSD/HDD, tamanho mínimo e Yescrypt são melhorias
novas e conscientes, não uma cópia literal dos scripts aposentados.

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

## Pendências

- Integrar os serviços à API v2 e ao pipeline de `target_tree`.
- Remover o fluxo v1 que ainda aceita plaintext e grava hash em módulo Nix.
- Implementar persistência segura separada para PPPoE.
- Validar boot, import do pool, mounts e reboot ZFS em VM descartável.
- ZFS executável permanece `PARTIAL` até essa prova em VM.

## Próximo passo recomendado

Conectar o `DiskoRenderer` ao staging declarativo da árvore Git e usar
`SecretStore` somente depois da montagem, antes de liberar o `nixos-install`.

#kryonix #installer #ragos #rust #nixos #disko #zfs #security
