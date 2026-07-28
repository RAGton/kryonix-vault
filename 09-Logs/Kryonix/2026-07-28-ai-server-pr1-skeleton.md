# Kryonix AI Server — PR 1 (API declarativa, defaults e assertions)

Data: 2026-07-28
Agente: Aura (sessão Hermes MiniMax-M3)
Branches: `pr/ai-server-skeleton` em `kryonix`
Repos afetados:

- `kryonix` (modules/nixos/services/ai-server/*)
- `kryonix-vault` (este log)
- `kryonix-dev` (a atualizar — pointer do vault)

## Objetivo

Estabelecer a fundação declarativa do produto **Kryonix AI Server**: um
orquestrador genérico 24/7 que hospede qualquer agente (Hermes, OpenClaw,
outro) sobre qualquer backend de inferência (llama.cpp, Ollama, externo),
com permissões, autonomia e modo de acesso remoto declarativos.

Este PR **NÃO** cria usuário, não toca SSH, não para serviços, não
substitui Ollama, não adiciona sudo. É estritamente:

- namespace `kryonix.services.aiServer`
- tipos fortes (enum, path, bool, attrs)
- defaults seguros
- assertions mínimas (4)
- registro em `services/default.nix`
- sem dependência de input externo (sem import de `hermes-agent` etc.)

## Contexto consultado

- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/05-brain-aura-home-assets-boundary|Aura como AURA_PRODUCT]] (decisão pendente — Aura continua separada)
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/08-pr-backlog|Backlog de PRs]] (PR #95 reservado para "separar Aura como produto")
- `modules/nixos/services/llama-cpp.nix` (já tem bind local + hardening + CUDA + DynamicUser)
- `modules/nixos/services/brain.nix` (já fala multi-backend via `llmProvider`)
- `modules/nixos/features/hermes.nix` (já roda em container podman — será integrado em PR 2)
- `modules/nixos/services/aura.nix` (wrapper shell — **intocado**, PR #95 cuida)
- `modules/nixos/services/default.nix` (imports canônicos)
- `lib/options.nix` (convenção `kryonix.*` + `services.<name>`)

## Decisões arquiteturais (canônicas)

| Decisão | Motivo |
|---|---|
| Namespace público: `kryonix.services.aiServer` (camelCase) | Convenção `kryonix.services.*` já estabelecida (`brain`, `llama-cpp`, `aura`, `neo4j`). |
| Filesystem: `modules/nixos/services/ai-server/` (kebab-case) | Convenção pré-existente (`kryxd/`, `greetd-dms/`, `home-assistant/`). |
| Camada 1 (motor) sem mencionar Glacier, rocha, RTX 4060, IPs | Conforme regra "core limpo" do `kryonix/AGENTS.md` + boundary audit. |
| **Não** substituir `kryonix.services.aura` | Decisão pendente no PR #95. `aiServer` é hosting; `aura` é persona/produto. |
| **Não** importar `inputs.hermes-agent` nem `oci-containers` | Mantém eval leve e sem dependência de input binário; integração entra em PR 2. |
| **Não** criar `users.users.*` neste PR | Identity/permissions entram em PR 3. |
| **Não** tocar firewall / SSH | remoteAccess é apenas **declaração**; aplicação entra em PR 7. |

## API proposta (PR 1)

```nix
kryonix.services.aiServer = {
  enable = false;  # opt-in como tudo em services.*

  agent = {
    enable = false;
    provider = "hermes";           # enum hermes | openclaw | custom
    runtime = "podman";            # enum podman | systemd
  };

  inference = {
    enable = false;
    provider = "llama-cpp";        # enum llama-cpp | ollama | external
    modelPath = null;              # obrigatório quando provider = "llama-cpp"
  };

  autonomy = {
    level = "readOnly";            # enum readOnly | operator | developer | maintainer | unrestricted
    acknowledgeUnrestricted = false;
  };

  remoteAccess = {
    mode = "tailscale";            # enum disabled | lan | tailscale | wireguard | publicSsh | reverseProxy | cloudflareTunnel
    acknowledgePublicExposure = false;
  };
};
```

Defaults seguros:

- `enable = false` (opt-in).
- `autonomy.level = "readOnly"` (Aura nunca sobe privilégios por padrão).
- `remoteAccess.mode = "tailscale"` (não expõe nada por padrão).
- `remoteAccess.acknowledgePublicExposure = false` (toggles de exposição pública off).
- `agent.runtime = "podman"` (alinha com Hermes atual; integrável em PR 2).

## Assertions (validação no `nix flake check`)

1. `remoteAccess.mode = "publicSsh"` exige `acknowledgePublicExposure = true`.
2. `inference.enable = true && inference.provider = "llama-cpp"` exige
   `inference.modelPath ≠ null` (espelha o que `llama-cpp.nix` já faz
   internamente — mas declarado também no nosso nível de orquestração,
   para falhar cedo).
3. `autonomy.level = "unrestricted"` exige `acknowledgeUnrestricted = true`.
4. `agent.provider = "custom"` exige `agent.command != null` (preparado para
   PR 2; default `null` por enquanto não dispara falha porque o backend
   default `"hermes"` não está nesse enum).

## Mudanças realizadas

### Arquivos novos em `repos/kryonix`:

```
modules/nixos/services/ai-server/
├── default.nix        (entrypoint — importa as outras duas)
├── options.nix        (declare options; nenhuma config)
└── assertions.nix     (4 assertions; nenhuma config)
```

Patches:

- `modules/nixos/services/default.nix`: importa `./ai-server` ao lado de
  `./aura.nix`, `./llama-cpp.nix`, `./brain.nix`.

**Nenhum** patch em: `flake.nix`, `flake.lock`, hosts, profiles, `users/`,
`features/`, `services/{aura,llama-cpp,brain}.nix`.

## Validações executadas (planejadas; serão rodadas antes de push)

- `git status -sb` em `repos/kryonix`: working tree contendo apenas os 3
  arquivos novos + 1 patch.
- `nix flake check --no-build --keep-going --impure` em `repos/kryonix`:
  todas as 3 hosts (`inspiron`, `inspiron-nina`, `glacier`) avaliam sem
  erros; nenhum eval quebra por causa do novo módulo (que está
  `enable = false` por padrão e portanto inerte).
- `nix eval --impure .#nixosConfigurations.glacier.config.kryonix.services.aiServer.enable`:
  retorna `false` por padrão.
- `nix eval --impure` com payload de teste ativando `publicSsh` sem
  `acknowledgePublicExposure`: assertion dispara com mensagem esperada.
- Secret scan (`gitleaks`) no diff: CLEAN — módulo não introduz segredos.
- `git diff --stat`: total ≤ 150 linhas adicionadas.

## Riscos

- **Baixo**. Módulo é purely declarativo: nada é ativado por padrão.
- Único risco real: regressão de avaliação se algum host tiver opção
  conflitante. Mitigação: o módulo declara tudo dentro de
  `config.kryonix.services.aiServer = { … }`, namespace já separado.

## Pendências (próximas fases)

- **PR 2** — Integração com módulos existentes: ligar `agent.runtime =
  "podman"` ao `inputs.hermes-agent.nixosModules.default` (sem duplicar a
  config do `hermes.nix` do Glacier; só expor a opção de forma genérica).
- **PR 3** — Identity: `users.users.${cfg.identity.user}` com `isSystemUser`,
  `home`, `extraGroups = []`, sem `wheel`.
- **PR 4** — Helper `kryx-agent-control` em `packages/kryx-agent-control/`
  com whitelist fechada (start/stop/status por **nome de serviço**, sem
  aceitar argumentos arbitrários para `systemctl`).
- **PR 5** — `kryx-cli`: adicionar `ai`, `agent`, `mode` em
  `repos/kryx-cli/src/cli/mod.rs`.
- **PR 6** — Profile `kryonix.profiles.ai-server.enable = true` com
  defaults seguros (tailscale, readOnly, sem push git, sem sudo
  genérico, inferência opcional).
- **PR 7** — Aplicação no Glacier: `kryonix.services.aiServer.enable =
  true` em `hosts/glacier/default.nix`, mantendo Ollama como transição
  via `inference.provider = "ollama"` e cortando para `"llama-cpp"` em
  PR 8 depois de validar modelos.
- **PR 8** — Glacier: substituir Ollama por llama.cpp no
  `glacier-ai` profile; `acceleration = "cuda"`; `autonomy.level =
  "operator"`.

## Próximo passo recomendado

1. Em `repos/kryonix/`: `git switch -c pr/ai-server-skeleton`,
   `mkdir -p modules/nixos/services/ai-server`, criar os 3 arquivos
   via `write_file`, patchar `services/default.nix`, rodar
   `nix flake check --no-build --keep-going --impure`, `gitleaks
   detect --no-banner --redact` no diff.
2. `git add <arquivos explícitos>` (sem `git add .`), commit com
   mensagem `feat(nixos): add kryonix.services.aiServer skeleton (PR 1)`.
3. Atualizar `repos/kryonix-vault` com este log (commit
   `docs(vault): log ai-server skeleton PR 1`).
4. Atualizar pointer do vault em `repos/kryonix-dev` (commit
   `chore(dev): update vault submodule pointer`).
5. **Gate humana** antes de push e PR.

Gate humana: nenhuma alteração é push sem `kryonix check --host glacier`
verde e revisão de Gabriel.
