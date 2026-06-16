---
title: Kryonix Installer - Requisitos Técnicos
type: documentation
status: draft
tags: [kryonix, installer, architecture, nixos, requirements]
project: kryonix
created: 2026-06-15
updated: 2026-06-15
---

# Requisitos Técnicos - Kryonix Installer

<role>
Atuando como Arquiteto de Sistemas e Especialista em NixOS para definir as bases do instalador declarativo do ecossistema Kryonix.
</role>

## Resumo
Esta nota define os requisitos funcionais e técnicos para o **Kryonix Installer**, garantindo que a instalação de novos nodes seja idempotente, declarativa e integrada ao `[[01-MOCs/Mapa - Kryonix]]`.

## Contexto e Conexões
- **MOC Pai:** [[01-MOCs/Mapa - Kryonix]]
- **Subsistema:** Installer
- **Relacionado:** [[02-Areas/Kryonix/architecture/Kryonix Architecture - Overview]]

---

<facts>
- O instalador deve gerar uma configuração NixOS válida e bootável.
- O particionamento deve suportar ZFS com criptografia nativa por padrão.
- A comunicação inicial para registro do host ocorre via mTLS com o Kryonix-Brain.
</facts>

<best_practices>
- Usar `disko` (Nix) para definição de partições como código.
- Implementar "Hardware Discovery" antes de iniciar a escrita em disco.
- Manter o instalador minimalista, rodando inteiramente em RAM (kexec/ISO).
</best_practices>

## Requisitos Detalhados (TOON)

```toon
categoria,          requisito,                                  prioridade
provisionamento,    suporte a instalação via PXE/iPXE,          alta
particionamento,    configuração via declarativa (disko),       crítica
segurança,          geração de chaves SSH/Age via TPM2,         alta
rede,               configuração automática de LACP/VLANs,      média
integração,         registro automático no Mapa - Hosts,        alta
branding,           interface TUI (Terminal UI) customizada,    baixa
```

<opinion>
Acredito que devemos priorizar a instalação via `nixos-anywhere` para facilitar o provisionamento remoto, reduzindo a necessidade de intervenção física com mídias USB. O instalador local (ISO) deve ser apenas um fallback.
</opinion>

<risks>
- **Incompatibilidade de Hardware:** Drivers específicos de storage/rede podem exigir kernels customizados na ISO de instalação.
- **Race Condition:** Tentativa de registro no Brain antes da rede estar 100% estável no primeiro boot.
</risks>

---

## Procedimento de Validação
1. **Dry-run:** Executar `nixos-anywhere --dry-run` para validar o arquivo de hardware gerado.
2. **Schema Check:** Validar se o JSON de registro enviado ao Brain segue o esquema em `[[02-Areas/Kryonix/canonical/Kryonix Entity Schema]]`.

## Links de Referência
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
- [[02-Areas/Kryonix/hosts/Kryonix Host Inventory]]

## Próximos Passos
- [ ] Definir o template `disko` padrão para workstations vs servidores.
- [ ] Criar protótipo da TUI em Rust ou Go para o "Kryonix Setup Wizard".