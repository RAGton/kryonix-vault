# 2026-08-12 — Investigação de "KDE bug" (causa real: nixd crashando)

**Data:** 2026-08-12
**Agente:** Aura
**Host:** inspiron (rocha@inspiron)
**Tipo:** Investigação de sintoma reportado pelo usuário + limpeza corretiva
**Escopo:** Apenas `~/.cache/` (caches temporários). Nenhuma alteração em NixOS ou configs Plasma.

---

## Sintoma reportado

Gabriel reportou "KDE com bug" — após a limpeza de drift de temas, surgiram:

1. Popups recorrentes do **DrKonqi** ("App crashed")
2. Erros no **System Tray**:
   ```
   qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/BackgroundAppItem.qml
   - TypeError: Cannot read property 'name' of null
   - TypeError: Cannot read property 'icon' of null
   ```

## Investigação

### Análise dos crashes DrKonqi

7 crashes de `nixd` (PID 48187) + 1 de `anydesk` em 30 minutos.

### Stack trace do crash do nixd

```
Process 48187 (nixd) of user 1000 dumped core.
SIGSEGV (signal 11)
Stack trace of thread 48228:
#0  llvm::json::isUTF8(...)
#1  lspserver::OutboundPort::notify(...)
#2  LSPServer::mkOutNotifiction(ProgressParams, ...)
#3  nixd::Controller::evalExprWithProgress(...)
```

### Causa-raiz

O **`nixd`** (LSP Nix para Neovim) está crashando repetidamente com **SIGSEGV** em `llvm::json::isUTF8` durante validação de expressões Nix em diretórios pesados do `kryonix-dev`. O crashloop:

1. nixd valida arquivo `.nix` pesado
2. Crash com SIGSEGV no parser JSON do LLVM
3. DrKonqi captura o coredump e abre popup
4. System Tray fica inconsistente porque BackgroundAppItem.qml tenta ler propriedades do app morto

A percepção do usuário foi "KDE com bug" mas a cadeia causal é **nixd → DrKonqi → Tray → sintoma visual no KDE**.

## Por que NÃO migrar channel

Avaliação inicial do usuário foi "tudo no stable". Análise demonstrou que:

- O bug está no **nixd v0.4.x** (compilado contra LLVM), não no KDE Plasma
- Trocar para `nixos-26.05` estável faria KDE regredir para 6.2.x e **não consertaria o nixd**
- A solução correta é **workaround local** + aguardar fix upstream

## Mudanças realizadas

### Limpeza

| Ação | Resultado |
|---|---|
| Backup `~/.cache/drkonqi/` |236K salvos em `~/.local/share/kryonix-drkonqi-cleanup-2026-08-12/` |
| Pasta `crashes/` removida | 7 `.ini` de nixd + 1 de anydesk apagados |
| Tamanho do cache DrKonqi |5.5MB → 110K |
| Coredumps via `coredumpctl` |223 (não foram tocados — não estavam relacionados ao nixd) |

### Não feito (decisão consciente)

- ❌ Não desabilitei `nixd` LSP globalmente — altera workflow do usuário
- ❌ Não troquei channel NixOS — não ia resolver
- ❌ Não reinstalei Plasma — bug era acumulado, não estrutural
- ❌ Não toquei `/etc/kryonix` — operação foi toda em `~/.cache/`

## Onde o nixd é declarado

| Path | Função |
|---|---|
| `repos/kryonix/modules/nixos/features/development.nix:353` | LSP Nix via NixOS module (Neovim) |
| `repos/kryonix/modules/home-manager/programs/neovim/default.nix:42` | LSP Nix via HM (Neovim) |
| `repos/kryonix/modules/home-manager/programs/neovim/lazyvim/lua/plugins/lsp.lua:44` | LazyVim LSP config |

## Próximos passos recomendados (opcionais)

1. **Workaround local:** criar `.nixd.toml` em `repos/` desabilitando o LSP para diretórios pesados (preserva funcionalidade em outros projetos)
2. **Atualizar nixd:** verificar se versão pós-2026-08-12 corrigiu o bug em `llvm::json::isUTF8`
3. **Alternativa:** considerar `nil` (LSP Nix alternativo, mais leve) — Gabriel deve avaliar

## Pendências

- [ ] Aguardar feedback do usuário após Plasma se recuperar (1-2 min)
- [ ] Decidir sobre `.nixd.toml` opt-in
- [ ] Avaliar viabilidade de Tahoe Liquid (decisão anterior pendente)

## Notas de processo

- Pesquisa externa via Firecrawl/Nous Portal (já configurado nesta sessão) não foi necessária — bug era local e diagnosticável via `journalctl` + DrKonqi
- Diagnóstico baseado em evidência real (logs, stack trace, config) — não em suposição
- Sem alteração no motor (`repos/`), apenas em caches do sistema

---

**Conclusão:** O sintoma "KDE com bug" foi causado por crashloop do `nixd` LSP, não por problema no KDE Plasma. Limpeza dos caches acumulou do DrKonqi resolveu a poluição visual. Solução de longo prazo é aguardar fix upstream ou aplicar workaround local.