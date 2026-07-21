# Dívida técnica — teste de topology do installer

Data: 2026-07-16
Repo: `kryxd`

## Problema

O teste `api::install::tests::test_install_endpoint_rejects_unsupported_topology` está falhando na suíte Rust do `kryxd`.

Evidência observada:

```txt
assertion `left == right` failed
left: 202
right: 422
```

## Impacto

A suíte completa `cargo test` não fica verde enquanto esse teste não for revisado.

## Próxima ação

Revisar o contrato esperado do endpoint de install para topologias não suportadas: confirmar se o comportamento correto é rejeitar com `422` antes de aceitar o job, ou se o teste ficou obsoleto diante da nova pipeline assíncrona que retorna `202`.

## Links relacionados

- [[03-Projetos/Kryonix Installer]]
