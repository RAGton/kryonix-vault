---
title: Kryonix Entity Schema
type: schema
status: active
tags: [kryonix, schema, entity, canonical, json, jsonschema]
project: kryonix
created: 2026-06-15
updated: 2026-06-15
version: "1.0.0"
jsonschema: "https://json-schema.org/draft/2020-12/schema"
---

# Kryonix Entity Schema v1.0.0

## Objetivo

Definir o **schema JSON canônico** (Draft 2020-12) para todas as entidades do ecossistema Kryonix. Serve como "Verdade Única" para:

- Validação de registro automático de hosts no Kryonix Brain via mTLS.
- Validação de payloads de API do Kryonix Brain (CRUD de entidades).
- Geração de código tipado (Rust structs, Go types, TypeScript interfaces) via codegen.
- Templates de criação de entidades no vault.

## Resumo

Schema único composto por **5 definições** (`$defs`): `Host`, `Service`, `Repository`, `Issue`, `Command`. Cada entidade tem campos obrigatórios, opcionais, enumerações controladas e exemplos. Versão `1.0.0` — breaking changes exigem bump de versão major e ADR.

## Quando usar

- Validação de payload no endpoint `/api/v1/entities/*` do Kryonix Brain.
- Codegen: `schemars` (Rust), `go-jsonschema` (Go), `json-schema-to-typescript` (TS).
- Templates `kepano-obsidian-bases` para formulários de criação no vault.
- Validação `nixos-anywhere --dry-run` do arquivo de hardware gerado pelo Installer.

## Especificação JSON Schema (v1.0.0)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/RAGton/kryonix/blob/main/schemas/kryonix-entity-schema.json",
  "title": "Kryonix Entity Schema",
  "version": "1.0.0",
  "description": "Schema canônico de entidades do ecossistema Kryonix",
  "type": "object",
  "properties": {
    "entity": { "$ref": "#/$defs/EntityEnvelope" }
  },
  "required": ["entity"],
  "additionalProperties": false,
  "$defs": {
    "EntityEnvelope": {
      "type": "object",
      "properties": {
        "type": { "const": "entity" },
        "version": { "const": "1.0.0" },
        "kind": { "$ref": "#/$defs/EntityKind" },
        "payload": { "$ref": "#/$defs/PayloadUnion" },
        "metadata": { "$ref": "#/$defs/EntityMetadata" }
      },
      "required": ["type", "version", "kind", "payload", "metadata"],
      "additionalProperties": false
    },
    "EntityKind": {
      "type": "string",
      "enum": ["host", "service", "repository", "issue", "command"],
      "description": "Tipo discriminador da entidade"
    },
    "PayloadUnion": {
      "oneOf": [
        { "$ref": "#/$defs/Host" },
        { "$ref": "#/$defs/Service" },
        { "$ref": "#/$defs/Repository" },
        { "$ref": "#/$defs/Issue" },
        { "$ref": "#/$defs/Command" }
      ]
    },
    "EntityMetadata": {
      "type": "object",
      "properties": {
        "id": { "type": "string", "format": "uuid", "description": "UUID v7 (timestamp-ordered)" },
        "created_at": { "type": "string", "format": "date-time" },
        "updated_at": { "type": "string", "format": "date-time" },
        "created_by": { "type": "string", "description": "Identidade do criador (user/agent/system)" },
        "source": { "enum": ["installer", "brain-api", "cli", "manual", "sync"], "description": "Origem da criação" },
        "tags": { "type": "array", "items": { "type": "string" }, "default": [] }
      },
      "required": ["id", "created_at", "updated_at", "created_by", "source"],
      "additionalProperties": false
    },
    "Host": {
      "type": "object",
      "title": "Host",
      "description": "Host físico ou virtual gerenciado pelo ecossistema Kryonix",
      "properties": {
        "identity": { "$ref": "#/$defs/HostIdentity" },
        "hardware": { "$ref": "#/$defs/HostHardware" },
        "network": { "$ref": "#/$defs/HostNetwork" },
        "state": { "$ref": "#/$defs/HostState" },
        "role": { "$ref": "#/$defs/HostRole" },
        "location": { "$ref": "#/$defs/HostLocation" },
        "provisioning": { "$ref": "#/$defs/HostProvisioning" }
      },
      "required": ["identity", "hardware", "network", "state", "role", "provisioning"],
      "additionalProperties": false,
      "examples": [
        {
          "identity": { "hostname": "glacier", "fqdn": "glacier.kryonix.local", "machine_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890" },
          "hardware": { "cpu": "AMD Ryzen 9 7950X", "cpu_cores": 16, "ram_gb": 128, "storage": [{ "device": "/dev/nvme0n1", "type": "nvme", "size_gb": 2000, "fs": "zfs", "encrypted": true }], "gpu": "NVIDIA RTX 4090" },
          "network": { "interfaces": [{ "name": "eno1", "mac": "aa:bb:cc:dd:ee:ff", "ipv4": "10.0.0.10/24", "ipv6": "fd00::10/64", "vlan": 10, "bond": "bond0", "lacp": true }], "dns_servers": ["10.0.0.1", "1.1.1.1"], "ntp_servers": ["time.kryonix.local"] },
          "state": { "status": "provisioned", "health": "healthy", "last_checkin": "2026-06-15T10:30:00Z" },
          "role": { "primary": "brain-node", "capabilities": ["compute", "storage", "gpu"] },
          "location": { "rack": "home-lab", "position": "U1-U2", "datacenter": "home" },
          "provisioning": { "method": "nixos-anywhere", "iso_version": "24.11", "disko_profile": "workstation-zfs-encrypted", "installed_at": "2026-06-10T14:22:00Z", "installer_version": "1.0.0-rc1" }
        }
      ]
    },
    "HostIdentity": {
      "type": "object",
      "properties": {
        "hostname": { "type": "string", "pattern": "^[a-z0-9-]{1,63}$", "description": "RFC 1123 label" },
        "fqdn": { "type": "string", "format": "hostname", "description": "Fully Qualified Domain Name" },
        "machine_id": { "type": "string", "pattern": "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", "description": "D-Bus machine-id / systemd machine-id" }
      },
      "required": ["hostname", "fqdn", "machine_id"],
      "additionalProperties": false
    },
    "HostHardware": {
      "type": "object",
      "properties": {
        "cpu": { "type": "string" },
        "cpu_cores": { "type": "integer", "minimum": 1 },
        "ram_gb": { "type": "integer", "minimum": 1 },
        "storage": {
          "type": "array",
          "items": { "$ref": "#/$defs/StorageDevice" },
          "minItems": 1
        },
        "gpu": { "type": ["string", "null"] }
      },
      "required": ["cpu", "cpu_cores", "ram_gb", "storage"],
      "additionalProperties": false
    },
    "StorageDevice": {
      "type": "object",
      "properties": {
        "device": { "type": "string", "pattern": "^/dev/" },
        "type": { "enum": ["nvme", "ssd", "hdd", "usb", "loop"] },
        "size_gb": { "type": "integer", "minimum": 1 },
        "fs": { "enum": ["zfs", "ext4", "xfs", "btrfs", "fat32", "swap"] },
        "encrypted": { "type": "boolean", "default": true },
        "pool": { "type": ["string", "null"], "description": "ZFS pool name se fs=zfs" }
      },
      "required": ["device", "type", "size_gb", "fs", "encrypted"],
      "additionalProperties": false
    },
    "HostNetwork": {
      "type": "object",
      "properties": {
        "interfaces": {
          "type": "array",
          "items": { "$ref": "#/$defs/NetworkInterface" },
          "minItems": 1
        },
        "dns_servers": { "type": "array", "items": { "type": "string", "format": "ipv4" }, "default": ["1.1.1.1", "8.8.8.8"] },
        "ntp_servers": { "type": "array", "items": { "type": "string" }, "default": ["time.kryonix.local"] }
      },
      "required": ["interfaces"],
      "additionalProperties": false
    },
    "NetworkInterface": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "pattern": "^[a-z0-9]+$" },
        "mac": { "type": "string", "pattern": "^([0-9a-f]{2}:){5}[0-9a-f]{2}$" },
        "ipv4": { "type": "string", "pattern": "^\\d{1,3}(\\.\\d{1,3}){3}/\\d{1,2}$" },
        "ipv6": { "type": ["string", "null"], "pattern": "^([0-9a-f:]+)(/\\d{1,3})?$" },
        "vlan": { "type": ["integer", "null"], "minimum": 1, "maximum": 4094 },
        "bond": { "type": ["string", "null"] },
        "lacp": { "type": "boolean", "default": false }
      },
      "required": ["name", "mac", "ipv4"],
      "additionalProperties": false
    },
    "HostState": {
      "type": "object",
      "properties": {
        "status": { "enum": ["discovered", "provisioning", "provisioned", "decommissioning", "decommissioned", "error"], "description": "Estado do ciclo de vida" },
        "health": { "enum": ["healthy", "degraded", "unhealthy", "unknown"] },
        "last_checkin": { "type": "string", "format": "date-time" }
      },
      "required": ["status", "health", "last_checkin"],
      "additionalProperties": false
    },
    "HostRole": {
      "type": "object",
      "properties": {
        "primary": { "enum": ["brain-node", "worker", "storage", "gateway", "dev", "ci-runner", "monitoring", "backup"] },
        "capabilities": { "type": "array", "items": { "type": "string" }, "default": [], "description": "Ex: compute, storage, gpu, network, tpm" }
      },
      "required": ["primary"],
      "additionalProperties": false
    },
    "HostLocation": {
      "type": "object",
      "properties": {
        "rack": { "type": "string" },
        "position": { "type": "string", "description": "Ex: U1-U2" },
        "datacenter": { "type": "string", "default": "home" },
        "coordinates": { "type": ["object", "null"], "properties": { "lat": { "type": "number" }, "lon": { "type": "number" } } }
      },
      "additionalProperties": false
    },
    "HostProvisioning": {
      "type": "object",
      "properties": {
        "method": { "enum": ["nixos-anywhere", "manual-iso", "pxe", "kexec"] },
        "iso_version": { "type": "string", "description": "Ex: 24.11, unstable" },
        "disko_profile": { "type": "string", "description": "Perfil disko usado: workstation-zfs-encrypted, server-zfs-raid, etc" },
        "installed_at": { "type": "string", "format": "date-time" },
        "installer_version": { "type": "string" }
      },
      "required": ["method", "iso_version", "disko_profile", "installed_at", "installer_version"],
      "additionalProperties": false
    },
    "Service": {
      "type": "object",
      "title": "Service",
      "description": "Serviço de rede exposto por um host (Ingress, API, DB, etc.)",
      "properties": {
        "identity": { "$ref": "#/$defs/ServiceIdentity" },
        "endpoint": { "$ref": "#/$defs/ServiceEndpoint" },
        "health": { "$ref": "#/$defs/ServiceHealth" },
        "dependencies": { "type": "array", "items": { "type": "string", "format": "uuid" }, "description": "IDs de serviços dos quais depende" },
        "owner_host": { "type": "string", "format": "uuid", "description": "Host que roda este serviço" }
      },
      "required": ["identity", "endpoint", "health", "owner_host"],
      "additionalProperties": false,
      "examples": [
        {
          "identity": { "name": "kryonix-brain-api", "namespace": "core", "version": "1.2.0" },
          "endpoint": { "protocol": "https", "port": 8443, "path": "/api/v1", "tls": { "enabled": true, "cert_source": "acme" } },
          "health": { "check_path": "/health", "interval_sec": 10, "timeout_sec": 3, "healthy_threshold": 2, "unhealthy_threshold": 3 },
          "owner_host": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        }
      ]
    },
    "ServiceIdentity": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "pattern": "^[a-z0-9-]{1,63}$" },
        "namespace": { "type": "string", "pattern": "^[a-z0-9-]{1,63}$" },
        "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-z0-9.-]+)?$" }
      },
      "required": ["name", "namespace", "version"],
      "additionalProperties": false
    },
    "ServiceEndpoint": {
      "type": "object",
      "properties": {
        "protocol": { "enum": ["http", "https", "grpc", "tcp", "udp", "ws", "wss"] },
        "port": { "type": "integer", "minimum": 1, "maximum": 65535 },
        "path": { "type": "string", "default": "/" },
        "tls": { "type": "object", "properties": { "enabled": { "type": "boolean", "default": true }, "cert_source": { "enum": ["acme", "self-signed", "manual", "vault"] } } }
      },
      "required": ["protocol", "port"],
      "additionalProperties": false
    },
    "ServiceHealth": {
      "type": "object",
      "properties": {
        "check_path": { "type": "string", "default": "/health" },
        "interval_sec": { "type": "integer", "minimum": 1, "default": 10 },
        "timeout_sec": { "type": "integer", "minimum": 1, "default": 3 },
        "healthy_threshold": { "type": "integer", "minimum": 1, "default": 2 },
        "unhealthy_threshold": { "type": "integer", "minimum": 1, "default": 3 }
      },
      "additionalProperties": false
    },
    "Repository": {
      "type": "object",
      "title": "Repository",
      "description": "Repositório Git gerenciado ou consumido pelo ecossistema",
      "properties": {
        "identity": { "$ref": "#/$defs/RepoIdentity" },
        "source": { "$ref": "#/$defs/RepoSource" },
        "access": { "$ref": "#/$defs/RepoAccess" },
        "metadata": { "$ref": "#/$defs/RepoMetadata" }
      },
      "required": ["identity", "source", "access"],
      "additionalProperties": false,
      "examples": [
        {
          "identity": { "owner": "RAGton", "name": "kryonix-installer", "visibility": "private" },
          "source": { "url": "https://github.com/RAGton/kryonix-installer", "default_branch": "main", "clone_url": "git@github.com:RAGton/kryonix-installer.git" },
          "access": { "ssh_key_ref": "kryonix-github-deploy", "token_ref": null },
          "metadata": { "description": "Instalador declarativo do ecossistema Kryonix", "topics": ["nixos", "installer", "rust", "react"], "license": "MPL-2.0" }
        }
      ]
    },
    "RepoIdentity": {
      "type": "object",
      "properties": {
        "owner": { "type": "string" },
        "name": { "type": "string" },
        "visibility": { "enum": ["public", "private", "internal"] }
      },
      "required": ["owner", "name", "visibility"],
      "additionalProperties": false
    },
    "RepoSource": {
      "type": "object",
      "properties": {
        "url": { "type": "string", "format": "uri" },
        "default_branch": { "type": "string", "default": "main" },
        "clone_url": { "type": "string" }
      },
      "required": ["url", "clone_url"],
      "additionalProperties": false
    },
    "RepoAccess": {
      "type": "object",
      "properties": {
        "ssh_key_ref": { "type": ["string", "null"], "description": "Referência ao secret no vault/1Password" },
        "token_ref": { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "RepoMetadata": {
      "type": "object",
      "properties": {
        "description": { "type": "string" },
        "topics": { "type": "array", "items": { "type": "string" }, "default": [] },
        "license": { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "Issue": {
      "type": "object",
      "title": "Issue",
      "description": "Issue ou Pull Request rastreado no ecossistema",
      "properties": {
        "identity": { "$ref": "#/$defs/IssueIdentity" },
        "content": { "$ref": "#/$defs/IssueContent" },
        "state": { "$ref": "#/$defs/IssueState" },
        "relations": {
          "type": "object",
          "properties": {
            "repository": { "type": "string", "format": "uuid" },
            "assignees": { "type": "array", "items": { "type": "string" }, "default": [] },
            "labels": { "type": "array", "items": { "type": "string" }, "default": [] },
            "milestone": { "type": ["string", "null"] },
            "linked_entities": { "type": "array", "items": { "type": "string", "format": "uuid" }, "description": "Hosts, services, commands relacionados" }
          },
          "additionalProperties": false
        }
      },
      "required": ["identity", "content", "state", "relations"],
      "additionalProperties": false,
      "examples": [
        {
          "identity": { "number": 79, "source": "github", "source_id": "RAGton/kryonix#79" },
          "content": { "title": "chore(ci): fix pre-existing failing workflows", "body": "Workflows broken for weeks...", "is_pr": false },
          "state": { "status": "open", "closed_at": null, "closed_by": null },
          "relations": { "repository": "repo-uuid-here", "assignees": [], "labels": ["ci", "debt", "blocked"], "milestone": "RC1", "linked_entities": [] }
        }
      ]
    },
    "IssueIdentity": {
      "type": "object",
      "properties": {
        "number": { "type": "integer", "minimum": 1 },
        "source": { "enum": ["github", "gitlab", "gitea", "manual"] },
        "source_id": { "type": "string", "description": "Ex: owner/name#number" }
      },
      "required": ["number", "source", "source_id"],
      "additionalProperties": false
    },
    "IssueContent": {
      "type": "object",
      "properties": {
        "title": { "type": "string", "maxLength": 256 },
        "body": { "type": "string" },
        "is_pr": { "type": "boolean", "default": false }
      },
      "required": ["title", "body"],
      "additionalProperties": false
    },
    "IssueState": {
      "type": "object",
      "properties": {
        "status": { "enum": ["open", "closed", "draft", "merged", "wip"] },
        "closed_at": { "type": ["string", "null"], "format": "date-time" },
        "closed_by": { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "Command": {
      "type": "object",
      "title": "Command",
      "description": "Comando executável documentado (CLI, script, alias, task runner)",
      "properties": {
        "identity": { "$ref": "#/$defs/CommandIdentity" },
        "definition": { "$ref": "#/$defs/CommandDefinition" },
        "execution": { "$ref": "#/$defs/CommandExecution" },
        "documentation": { "$ref": "#/$defs/CommandDocumentation" }
      },
      "required": ["identity", "definition", "execution"],
      "additionalProperties": false,
      "examples": [
        {
          "identity": { "name": "kryonix", "namespace": "cli", "version": "1.0.0-rc1" },
          "definition": { "entrypoint": "/usr/bin/kryonix", "args_schema": { "type": "object", "properties": { "subcommand": { "type": "string", "enum": ["install", "status", "upgrade", "health"] }, "flags": { "type": "object", "properties": { "dry-run": { "type": "boolean" }, "target-host": { "type": "string" } } } } } },
          "execution": { "timeout_sec": 3600, "requires_sudo": true, "env": { "KRYONIX_CONFIG": "/etc/kryonix/config.yaml" } },
          "documentation": { "summary": "CLI principal do ecossistema Kryonix", "man_page": "kryonix(1)", "examples": ["kryonix install --target-host glacier", "kryonix status --all"] }
        }
      ]
    },
    "CommandIdentity": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "pattern": "^[a-z0-9-]{1,63}$" },
        "namespace": { "type": "string", "pattern": "^[a-z0-9-]{1,63}$" },
        "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-z0-9.-]+)?$" }
      },
      "required": ["name", "namespace", "version"],
      "additionalProperties": false
    },
    "CommandDefinition": {
      "type": "object",
      "properties": {
        "entrypoint": { "type": "string" },
        "args_schema": { "type": "object", "description": "JSON Schema dos argumentos/flags" }
      },
      "required": ["entrypoint", "args_schema"],
      "additionalProperties": false
    },
    "CommandExecution": {
      "type": "object",
      "properties": {
        "timeout_sec": { "type": "integer", "minimum": 1, "default": 300 },
        "requires_sudo": { "type": "boolean", "default": false },
        "env": { "type": "object", "additionalProperties": { "type": "string" }, "default": {} }
      },
      "additionalProperties": false
    },
    "CommandDocumentation": {
      "type": "object",
      "properties": {
        "summary": { "type": "string" },
        "man_page": { "type": ["string", "null"] },
        "examples": { "type": "array", "items": { "type": "string" }, "default": [] }
      },
      "additionalProperties": false
    }
  }
}
```

---

## Tabela de Referência Rápida (TOON)

```toon
entidade,        campos_obrigatorios,                                          enums_principais
Host,            identity, hardware, network, state, role, provisioning,       status, health, primary_role, fs_type, provision_method
Service,         identity, endpoint, health, owner_host,                       protocol, health_status
Repository,      identity, source, access,                                     visibility, default_branch
Issue,           identity, content, state, relations,                          status(open/closed/draft), is_pr
Command,         identity, definition, execution,                              namespace, requires_sudo
```

---

## Codegen e Integração

| Linguagem | Ferramenta | Comando |
|-----------|------------|---------|
| Rust | `schemars` + `serde` | `cargo run --bin generate-schema` |
| Go | `go-jsonschema` | `go run github.com/atombender/go-jsonschema@latest -o ./pkg/schema kryonix-entity-schema.json` |
| TypeScript | `json-schema-to-typescript` | `npx json-schema-to-typescript kryonix-entity-schema.json -o src/types/entities.ts` |
| Python | `pydantic` + `json-schema` | `python -m pydantic.tools.generate_schema kryonix_entity_schema` |

### Exemplo Rust (`EntityEnvelope`)

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::{DateTime, Utc};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum EntityPayload {
    Host(Host),
    Service(Service),
    Repository(Repository),
    Issue(Issue),
    Command(Command),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EntityEnvelope {
    #[serde(rename = "type")]
    entity_type: String, // const "entity"
    version: String,     // const "1.0.0"
    kind: EntityKind,
    payload: EntityPayload,
    metadata: EntityMetadata,
}
```

---

## Versionamento e Migração

| Versão | Data | Mudanças | ADR |
|--------|------|----------|-----|
| 1.0.0 | 2026-06-15 | Release inicial (Host, Service, Repository, Issue, Command) | — |

**Regra de breaking change:** qualquer campo `required` removido, `enum` reduzido, tipo alterado, ou `$defs` renomeado → **major bump** + ADR obrigatório.

---

## Checklist de Validação v1.0.0

- [x] Host cobre identidade, hardware, rede, estado, role, localização, provisioning
- [x] Service cobre identidade, endpoint, health, deps, owner_host
- [x] Repository cobre identidade, source, access, metadata
- [x] Issue cobre identidade, conteúdo, estado, relações
- [x] Command cobre identidade, definição, execução, docs
- [x] EntityEnvelope com discriminador `kind` + metadados UUIDv7
- [x] Exemplos válidos para cada tipo
- [x] Enums fechados para status, roles, fs types, provision methods

---

## Links Relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/installer/Kryonix Installer - Requisitos Técnicos]]
- [[02-Areas/Kryonix/hosts/Kryonix Host Inventory]]
- [[02-Areas/Kryonix/canonical/Architecture]]
- [[02-Areas/Kryonix/installer/MOC - Installer]]
- JSON Schema Draft 2020-12: <https://json-schema.org/draft/2020-12/>

## Próximos Passos

- [ ] Integrar validação `jsonschema` no CI do `kryonix-installer` (GitHub Actions).
- [ ] Gerar Rust structs via `schemars` no crate `kryonix-schema`.
- [ ] Gerar TypeScript types para UI do Installer.
- [ ] Adicionar schema de `Secret` (para Age/TPM2 keys) na v1.1.0.
- [ ] Documentar migração v1.0.0 → v1.1.0 (ADR).