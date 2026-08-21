# 2026-08-21 — fix(zsh): corrige `unmatched '` no .zshrc (KCR-ZSH-COMPLETION)

Data: 2026-08-21
Agente: Aura (sessão Hermes)
Repos afetados:

- `kryonixos` (users/rocha/inspiron/default.nix) — commit `6e23864`
- `kryonix-dev` (submodule pointer) — commit `2a6fc3d`

## Objetivo

Resolver o erro reportado pelo usuário ao rodar `kryx check`:

```text
(eval):1: can't change option: zle
(eval):1: can't change option: zle
(anon):setopt:7: can't change option: monitor
[ERROR]: gitstatus failed to initialize.
Add the following parameter to ~/.config/zsh/.zshrc for extra diagnostics on error:
GITSTATUS_LOG_LEVEL=DEBUG
Restart Zsh to retry gitstatus initialization:
exec zsh
/home/rocha/.config/zsh/.zshrc:184: unmatched '
```

## Diagnóstico

1. O `.zshrc` do usuário é um symlink para `/nix/store/8qza8bj4c3h64fha3w08hi5a673agx83-home-manager-files/.config/zsh/.zshrc` (gerado pelo `home-manager`).
2. O arquivo no Nix store tem **7773 bytes** e termina com `'\n    # kryx completion...` — o `'` literal na linha 180 é o que causa `unmatched '`.
3. O source of truth do `.zshrc` é `repos/kryonixos/users/rocha/inspiron/default.nix:325`, que define:

```nix
programs.zsh.initContent = pkgs.lib.mkAfter '''
    # kryx completion: tab complete para todos os 18 subcomandos
    if command -v kryx > /dev/null 2>&1; then
      eval "$(kryx completion zsh)"
    fi
  ''';
```

4. **Root cause**: o bloco usa `'''` (3 aspas) na abertura mas `''` (2 aspas) no fechamento. Em Nix, `'''` no início de uma string **adiciona um `'` literal como primeiro caractere** do conteúdo. O `'` extra é emitido pelo `home-manager` no `.zshrc` final, e o zsh quebra ao tentar parsear a string resultante.

Confirmado por teste empírico:

```text
let s = '''
content
  '';
in s
```

→ `'\ncontent\n'` (note o `'` literal no início).

## Mudanças realizadas

### `repos/kryonixos/users/rocha/inspiron/default.nix`

- Trocou `'''...'''` por `''...''` (forma canônica e simétrica de Nix indented string).
- Adicionou comentário explicativo alertando sobre o footgun do `'''` no Nix.
- Diff: `+3` linhas (comentário) e `-1` linha (`'''` → `''`).

```nix
  # kryx shell completion (Zsh). Carrega via eval no init do shell.
  # Funciona em conjunto com o lockdown — kryx é o único CLI permitido.
  # IMPORTANTE: usa '' (2 aspas), nao ''' (3 aspas). Em Nix, '''...''
  # com 3 aspas na abertura adiciona um ' literal como primeiro
  # caractere, o que quebra o zsh com unmatched '. (KCR-ZSH-COMPLETION)
  programs.zsh.initContent = pkgs.lib.mkAfter ''
    # kryx completion: tab complete para todos os 18 subcomandos
    if command -v kryx > /dev/null 2>&1; then
      eval "$(kryx completion zsh)"
    fi
  '';
```

## Commits

```text
kryonixos:    6e23864 fix(zsh): corrige 'unmatched' no .zshrc removendo ''' por ''
kryonix-dev:  2a6fc3d chore(dev): update kryonixos submodule (fix zsh unmatched quote)
```

## Validações executadas

- `nix flake check --keep-going --impure` em `kryonixos` → `all checks passed!` (inspiron, glacier, inspiron-nina).
- `nix eval` do `initContent` antes/depois do patch:
  - Antes: terminava em `alias -- v=nvim\n'\n    # kryx...` (com `'` solto).
  - Depois: termina em `alias -- v=nvim\n# kryx completion...\nfi\n` (correto).
- Tamanho: 7773 → 7755 bytes (caiu o `'` extra).
- `kryx switch` em background para regenerar o `.zshrc` no Nix store.

## Evidências

- `git show 6e23864` mostra o diff mínimo de 4 inserções e 1 deleção.
- `nix eval` substring do `initContent` final (200 últimos chars):

```text
"nix-obsidian\nalias -- ls='eza --icons always'\nalias -- v=nvim\n# kryx completion: tab complete para todos os 18 subcomandos\nif command -v kryx > /dev/null 2>&1; then\n  eval \"$(kryx completion zsh)\"\nfi\n"
```

## Pendências

- Confirmar que `kryx switch` rodou sem erros e o `.zshrc` no store foi regenerado.
- Validar que `kryx check` agora roda limpo sem `unmatched '`.
- Considerar adicionar uma regra de lint no CI do `kryonixos` que detecte `'''...'` ou `''...'''` assimétricos em `initContent` e outros blocos multi-linha Nix.

## Próximo passo recomendado

1. Após `kryx switch` terminar, executar `kryx check` novamente para confirmar.
2. Salvar este incidente como referência no playbook de troubleshooting do kryonixos.
3. Adicionar smoke test ao CI que rode `nix eval` em `home-manager.users.rocha.programs.zsh.initContent` e falhe se contiver `'\n` (aspa literal antes de newline) — sintoma direto desse bug.
