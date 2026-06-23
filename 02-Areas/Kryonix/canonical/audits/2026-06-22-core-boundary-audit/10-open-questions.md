# Perguntas em aberto — CORRIGIDO

| # | Pergunta | Impacto | Resposta parcial (Evidence Pack) | Status |
|---|---|---|---|---|
| 1 | `hosts/inspiron` no core é resíduo? | Alto | ✅ SIM — flake só exporta `iso`. Resíduo confirmado. | **RESOLVIDO** |
| 2 | `profiles/glacier-*.nix` devem sair do core? | Alto | ❌ NÃO — são ATIVOS. Downstream usa. Decisão arquitetural. | 🔴 Pendente decisão |
| 3 | Aura deve virar repo próprio? | Médio | — | 🔴 Pendente (Gabriel) |
| 4 | Desktop assets devem sair do core? | Médio | ✅ Assets sim. Config funcional NÃO. | 🟡 Parcial resolvido |
| 5 | ISO deve ser movida para installer? | Alto | — | 🔴 Pendente |
| 6 | `.agents/` é LEGACY? | Baixo | ❌ NÃO — é canônico ativo. AGENTS.md referencia. | **RESOLVIDO** |
| 7 | Submódulo brain-lightrag está sincronizado? | Médio | ✅ NÃO — `58d905d` vs `95dfc2e` (DESATUALIZADO) | **RESOLVIDO** |
| 8 | `kryonix-home` é consumido via input? | Médio | ✅ SIM — `inputs.kryonix-home` definido em `flake.nix:96` | **RESOLVIDO** |
| 9 | `kryonix-hardware-probe` deve ir para installer? | Médio | ❌ NÃO — é CORE_SHARED (usado pela CLI também) | **RESOLVIDO** |
