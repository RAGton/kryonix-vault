---
title: Fonte - Pacote RioMar SLIM para Active Directory
type: reference
status: preserved
created: 2026-07-29
tags: [active-directory, powershell, fonte, anexo]
---

# Fonte — Pacote RioMar SLIM para Active Directory

## Origem

Anexo fornecido por Gabriel Rocha em 2026-07-29: `riomar-slim.zip`.

A extração foi preservada sem alterações em:

- [[08-Referencias/Active Directory/riomar-slim/README]]
- `08-Referencias/Active Directory/riomar-slim/scripts/`
- `08-Referencias/Active Directory/riomar-slim/templates/`

## Integridade da extração

| Arquivo | SHA-256 |
|---|---|
| `README.md` | `ec980680766833d923541326e47c6afc400e2e186d9f5c2e5bb9d984d4047a21` |
| `scripts/New-RIOArvore.ps1` | `28910f7ec105824c458fd786673fb19d77f671366201e1d25631057cf6c430b7` |
| `scripts/New-RIOCompartilhado.ps1` | `bb0a3bea25a3072d6c62763b58d05b442a7e31500847e0f5614c4a052f00e372` |
| `scripts/New-RIOUsuarios.ps1` | `ed02923cb1c23a3c356f2c514c70733967ad12dd15c8be665a20300ef5320a98` |
| `templates/funcionarios.csv` | `e549ce9cea21236ae90cd64a6a4d2c80f31267c425572ede79025da11e43029f` |

## Aviso de segurança

> [!danger]
> Esta pasta é **fonte histórica**, não baseline aprovado para produção. Ela contém pressupostos específicos da RioMar e limitações documentadas no runbook generalizado. Não execute diretamente em outro ambiente.

## Revisão técnica independente

Uma revisão estática independente confirmou estes riscos prioritários na fonte original:

| Severidade | Achado | Tratamento no baseline genérico |
|---|---|---|
| Crítica | share concede leitura a `Authenticated Users`, além do grupo autorizado | removido; acesso limitado ao grupo Domain Local do recurso |
| Crítica | `SetAccessRuleProtection($true, $false)` pode apagar ACL herdada de pasta existente | pasta existente exige aceite explícito antes de substituir a ACL |
| Alta | ACL usa nomes localizados como `SYSTEM` e `BUILTIN\Administrators` | contas conhecidas são resolvidas por SID |
| Alta | CSV aceita senha em texto claro | coluna de senha removida |
| Alta | senhas geradas aparecem no console | risco mantido explícito somente no modo de geração; uso interativo pode solicitar `SecureString` |
| Alta | gerador usa `Get-Random`, que não é CSPRNG | substituído por `RandomNumberGenerator` |
| Média | grupos ficam dentro da OU de usuários | criada OU `Grupos` separada |
| Média | consultas por `-LDAPFilter` interpolam DN sem escape | baseline usa `-Identity` para DNs conhecidos |
| Média | função de OU depende da variável `$Desc` do escopo externo | descrição virou parâmetro explícito |
| Média | share existente não tem permissões reconciliadas na reexecução | baseline recusa mudanças perigosas e exibe o estado existente para revisão |
| Média | ausência de ABE e criptografia SMB | ABE e `EncryptData` habilitados no template |
| Operacional | pacote pressupõe domínio e OU raiz previamente criados | baseline inclui instalação e pre-check da primeira floresta |
| Operacional | grupos administrativos são criados, mas não recebem delegação/GPO | runbook declara a separação e documenta delegação mínima |
| Operacional | não há segundo DC, replicação, LAPS ou recuperação testada | incorporados como fases obrigatórias/recomendadas do runbook |

A revisão foi somente estática: não houve execução da fonte original contra um domínio Windows.

## Derivação segura e reutilizável

- [[04-Recursos/playbooks/runbooks/Active Directory - Implantacao Baseline/README|Runbook - Active Directory para empresas]]
- [[01-MOCs/Mapa - DevOps e SRE]]
- [[01-MOCs/Mapa - Segurança]]
