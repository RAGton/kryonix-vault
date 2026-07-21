# Auditoria de remoto, pendências e próximos passos — Kryonix

Data: 2026-07-21
Agente: Aura
Repos afetados:

- `/home/rocha/kryonix-dev`
- `/home/rocha/kryonix-dev/repos/*`
- `/home/rocha/kryonix-dev/raw/*`
- `/etc/kryonix`
- `/etc/kryonixos`

Links relacionados:

- [[VAULT_INDEX]]
- [[03-Projetos/Kryonix System]]
- [[02-Areas/Kryonix/canonical/Operations|Kryonix · Operations]]
- [[02-Areas/Kryonix/systems/Inspiron|Host: Inspiron]]

## Objetivo

Registrar o que ainda não está no remoto, o que está divergente em relação ao remoto, se existe conflito ativo e quais próximos passos são seguros.

## Resumo executivo

- Não há conflito de merge ativo em nenhum repositório inspecionado.
- `repos/kryx-cli` está sincronizado com `origin/main` depois do commit `8ed4705 feat(doctor): add host-aware diagnostics with json output`.
- `/etc/kryonix` está sincronizado com `origin/main`.
- `/etc/kryonixos` está sincronizado com `origin/main`, mas contém `hosts/inspiron/disks.nix` untracked.
- Três submódulos DEV estão atrás do remoto em 1 commit cada: `kryonix-aura`, `kryonix-brain-lightrag`, `kryonix-home`.
- O meta-repo possui gitlinks `raw/*` rastreados, mas sem entradas correspondentes em `.gitmodules`; isso faz `git submodule status --recursive` falhar com `fatal: no se ha encontrado mapeo de submódulos en .gitmodules para la ruta 'raw/kryonix'`.

## Tabela — o que não está no remoto ou não está alinhado

| Escopo | Estado | Está no remoto? | Conflito ativo? | Por que está assim | Risco | Próximo passo recomendado |
|---|---:|---|---|---|---|---|
| `/etc/kryonixos/hosts/inspiron/disks.nix` | Untracked | Não | Não | Arquivo Disko/storage local, com particionamento e formatação do NVMe; foi deixado fora de propósito para não versionar operação destrutiva “no embalo”. | Alto | Auditar separadamente; decidir se vira contrato oficial de instalação, arquivo local ignorado ou nota no Vault. Não commitar sem revisão humana. |
| `repos/kryonix-aura` | Behind 1 | Remoto tem commit a mais | Não | O clone local está 1 commit atrás de `origin/main`: `939f179 chore: save local modifications before format`. | Baixo/Médio | Rodar `git -C repos/kryonix-aura pull --ff-only` quando quiser sincronizar; depois atualizar pointer no `kryonix-dev` se o submódulo avançar. |
| `repos/kryonix-brain-lightrag` | Behind 1 | Remoto tem commit a mais | Não | O clone local está 1 commit atrás de `origin/main`: `7eb3403 chore: save local modifications before format`. | Médio | Rodar `git -C repos/kryonix-brain-lightrag pull --ff-only`; validar fluxo Python/Brain se for usar imediatamente; atualizar pointer no meta-repo. |
| `repos/kryonix-home` | Behind 1 | Remoto tem commit a mais | Não | O clone local está 1 commit atrás de `origin/main`: `4bef654 chore: save local modifications before format`. | Baixo/Médio | Rodar `git -C repos/kryonix-home pull --ff-only`; validar Rust/Home se necessário; atualizar pointer no meta-repo. |
| `raw/kryonix`, `raw/kryonix-aura`, `raw/kryonix-brain-lightrag`, `raw/kryonix-home`, `raw/kryonix-installer` | Gitlinks rastreados sem `.gitmodules` | Parcial/ambíguo | Não é merge conflict; é inconsistência de submodule metadata | Os caminhos `raw/*` existem como gitlinks (`160000`) no índice, mas não têm mapeamento em `.gitmodules`. | Médio | Em tarefa separada, decidir: remover gitlinks `raw/*`, restaurar entradas `.gitmodules`, ou migrar para diretório não-submodule. Não fazer junto com feature. |
| `repos/kryonix-vault` | Novo log criado nesta tarefa | Ainda não até o commit/push desta nota | Não | Relatório operacional solicitado pelo Gabriel. | Baixo | Commitar no Vault e atualizar pointer do submódulo no `kryonix-dev`. |

## Tabela — repositórios verificados

| Repo | Branch | Ahead | Behind | Working tree | Observação |
|---|---|---:|---:|---|---|
| `/home/rocha/kryonix-dev` | `main` | 0 | 0 | limpo antes deste log | Meta-repo sincronizado, mas `git submodule status --recursive` falha por `raw/*` sem `.gitmodules`. |
| `repos/kryonix` | `main` | 0 | 0 | limpo | Motor sincronizado. |
| `repos/kryonix-assets` | `main` | 0 | 0 | limpo | Assets sincronizado. |
| `repos/kryonix-aura` | `main` | 0 | 1 | limpo | Precisa fast-forward se for usar. |
| `repos/kryonix-brain-lightrag` | `main` | 0 | 1 | limpo | Precisa fast-forward se for usar. |
| `repos/kryonix-home` | `main` | 0 | 1 | limpo | Precisa fast-forward se for usar. |
| `repos/kryonix-vault` | `main` | 0 | 0 | este relatório novo | Será commitado nesta tarefa. |
| `repos/kryonixos` | `main` | 0 | 0 | limpo | Downstream DEV sincronizado. |
| `repos/kryx-cli` | `main` | 0 | 0 | limpo | Doctor host-aware já commitado e pushado: `8ed4705`. |
| `repos/kryxd` | `main` | 0 | 0 | limpo | Daemon sincronizado. |
| `/etc/kryonix` | produção | 0 | 0 | limpo | Produção motor sincronizada. |
| `/etc/kryonixos` | `main` | 0 | 0 | `?? hosts/inspiron/disks.nix` | Produção downstream sincronizada exceto arquivo Disko local não versionado. |

## Evidências executadas

```bash
git -C /home/rocha/kryonix-dev status -sb
git -C /home/rocha/kryonix-dev/repos/kryx-cli status -sb
git -C /home/rocha/kryonix-dev/repos/kryx-cli log --oneline -3
sudo git -C /etc/kryonixos status -sb
git -C /home/rocha/kryonix-dev ls-files -s | awk '$1=="160000" {print $4}'
git -C /home/rocha/kryonix-dev config --file .gitmodules --get-regexp 'submodule\..*\.path'
git -C <repo> diff --name-only --diff-filter=U
```

Resultados relevantes:

```text
/etc/kryonixos:
## main...origin/main
?? hosts/inspiron/disks.nix
```

```text
repos/kryx-cli:
## main...origin/main
8ed4705 feat(doctor): add host-aware diagnostics with json output
```

```text
git submodule status --recursive:
fatal: no se ha encontrado mapeo de submódulos en .gitmodules para la ruta 'raw/kryonix'
```

```text
Unmerged files: nenhum resultado em todos os repos inspecionados.
```

## Decisões

1. Não versionar `hosts/inspiron/disks.nix` automaticamente, porque ele contém contrato Disko/storage com potencial destrutivo.
2. Não fazer `pull --ff-only` automático nos três repos DEV atrasados dentro desta tarefa; isso deve ser uma sincronização separada para evitar misturar relatório, Vault e atualização de submódulos.
3. Registrar a inconsistência `raw/*` vs `.gitmodules` como pendência estrutural do meta-repo, sem tentar corrigir no mesmo commit.

## Próximos passos recomendados

| Prioridade | Ação | Comando seguro sugerido | Critério de conclusão |
|---:|---|---|---|
| 1 | Decidir destino de `/etc/kryonixos/hosts/inspiron/disks.nix` | `sudo git -C /etc/kryonixos diff -- /etc/kryonixos/hosts/inspiron/disks.nix` não se aplica por untracked; revisar conteúdo manualmente | Decisão explícita: versionar em commit próprio, ignorar, mover para Vault, ou remover com autorização. |
| 2 | Sincronizar submódulos DEV atrasados | `git -C repos/kryonix-aura pull --ff-only`; idem Brain/Home | Cada repo `## main...origin/main`; meta-repo com pointers atualizados e commitados. |
| 3 | Corrigir metadata de `raw/*` | Auditar `git ls-files -s raw/*`, `.gitmodules` e histórico | `git submodule status --recursive` volta a executar sem fatal. |
| 4 | Criar `kryx switch check` | Implementar read-only em `repos/kryx-cli` usando `CheckResult` | `cargo check`, `cargo run -- switch check`, `nix build .#default --no-link`. |

## Estado

READY_FOR_REVIEW

## Pendências

- `hosts/inspiron/disks.nix` continua fora do Git por segurança.
- `raw/*` continua com inconsistência de submodule metadata.
- `kryonix-aura`, `kryonix-brain-lightrag` e `kryonix-home` continuam atrás do remoto até sincronização explícita.

#kryonix #operacoes #git #submodules #vault
