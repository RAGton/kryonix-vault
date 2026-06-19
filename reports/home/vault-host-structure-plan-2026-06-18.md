# Plano de Organização do Home/Vault – 2026‑06‑18

> **Objetivo:** Criar a nova estrutura lógica de diretórios dentro do vault (`/home/rocha/kryonix/kryonix-vault`) para separar documentação por host, sem mover ou remover nenhum arquivo existente.  
> **Escopo:** Apenas criação de diretórios vazios e geração de artefatos de planejamento (relatório e manifesto).  
> **Regras observadas:**  
> - Nenhum arquivo foi movido, apagado ou substituído.  
> - Nenhum symlink foi criado.  
> - Nenhum dot‑dir runtime (`.cache`, `.config`, `.local`, `.var`, `.hermes`, `.gemini`, `.mozilla`, `.rustup`, `.cargo`) foi tocado.  
> - Todos os comandos foram executados de forma declarativa (`mkdir -p`).  
> - O plano está documentado aqui e será revisado (`needs_review: true`) antes de qualquer migração real.

---

## 1️⃣ Estrutura de diretórios criada

### Hosts

| Host | Sub‑pastas criadas (exemplo) |
|------|------------------------------|
| `hosts/inspiron/` | `hardware/`, `network/`, `storage/`, `services/`, `logs/`, `incidents/`, `validation/`, `screenshots/`, `brain-client/` |
| `hosts/inspiron-nina/` | `hardware/`, `network/`, `storage/`, `services/`, `logs/`, `incidents/`, `validation/`, `screenshots/` |
| `hosts/glacier/` | `hardware/`, `network/`, `storage/`, `services/`, `logs/`, `incidents/`, `validation/`, `screenshots/`, `brain-server/`, `gpu/`, `ollama/`, `neo4j/`, `lightrag/`, `libvirt/`, `backups/` |
| `hosts/iso/` | `builds/`, `boot/`, `installer/`, `libvirt-tests/`, `screenshots/` |

### Projects (Kryonix)

```
projects/Kryonix/
├─ installer/
├─ brain/
├─ cli/
├─ iso/
├─ nixos/
├─ vault/
```

### Logs

```
logs/
├─ prs/
├─ builds/
├─ backups/
├─ evidence/
├─ e2e/
└─ incidents/
```

### Reports

```
reports/home/
├─ vault-host-structure-plan-2026-06-18.md
├─ vault-host-structure-manifest-2026-06-18.json
├─ inventory/
└─ (outros futuros relatórios)
```

### Configs (non‑secret)

```
configs/
├─ non-secret/
├─ examples/
└─ schemas/
```

### Templates

```
templates/
├─ host-readme.md
├─ validation-log.md
├─ incident.md
├─ hardware-snapshot.md
└─ e2e-report.md
```

### Assets

```
assets/
├─ images/
├─ screenshots/
└─ ragos/
```

---

## 2️⃣ Próximos passos (dry‑run)

1. **Revisar** este plano e o manifesto gerado (`vault-host-structure-manifest-2026-06-18.json`).  
2. **Aprovar** as proposições marcando `needs_review: false` após a análise.  
3. ** Executar ** apenas auditorias (`git status`, `git diff`, `find …`) para confirmar que nada foi alterado.  
4. **Quando aprovado**, podemos criar um script de *dry‑run* que apenas lista as ações previstas, sem tocar em arquivos.

---

> **Nota:** Este documento serve como referência para o próximo ciclo de migração. Todas as alterações propostas ainda estão em *dry‑run* e precisam da sua validação explícita antes de qualquer movimentação real. 