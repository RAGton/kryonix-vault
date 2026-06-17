# PR-005 - Live Remote Web Boot Mode

## Fato
Foi implementado um modo de operação remota seguro para o live installer do Kryonix. O modo pode ser acionado via GRUB escolhendo a specialisation `Installer (Remote Web)`.
Ele abrange configurações nos repositórios `kryonix` (ISO) e `kryonix-installer` (Backend/Frontend).

## Decisão
- A detecção é feita em tempo de execução inspecionando `/proc/cmdline` pelo parâmetro `kryonix.installer.mode=remote`.
- Se detectado o modo remoto, o instalador não inicia o Cage/Chromium em kiosk.
- Um token randômico é gerado e exposto na interface TTY (juntamente com o IP da LAN).
- A porta `8080` (onde o instalador serve backend e frontend) está aberta incondicionalmente no NixOS ISO, mas a exposição local vs LAN é mitigada pelo bind address do rust: `127.0.0.1` em modo local e `0.0.0.0` em modo remoto.
- Todas as APIs são interceptadas via Middleware (com exceção do `/health` e frontend estático) exigindo um `Authorization: Bearer <token>`.
- O Frontend intercepta falhas `401 Unauthorized` e força o desvio da rota para uma barreira de login (Login.jsx), armazenando o token no `sessionStorage`.

## Validação
- `cargo test` no backend, validando regras estruturais.
- `npm test` na UI (testes unitários).
- `nix flake check --no-build` na configuração do host.
- A exclusão do endpoint `/health` da camada de auth permitiu que o poll healthcheck bash funcionasse normalmente.

## Riscos
- Risco mínimo de brute-force no token de sessão por estar exposto na rede local até que o usuário conclua a instalação, mas mitigado pelo caráter efêmero do live system e de ser uma senha randômica hexadecimal de 32 bytes gerada dinamicamente e sem limite de tentativas por enquanto (API não tem rate-limit por padrão).
- Risco documentado do `sessionStorage` para ataques XSS - mitigável uma vez que a página está servida num ambiente confinado por nós e sem scripts de terceiros.
- Alterar o `mkForce` no Plymouth `default.nix` para `mkOverride 10` foi necessário para sobrepor no modo de debug do ISO sem causar evaluation crash do flake.

## Próximos Passos
- Fazer Push dos branches.
- Abrir PR no repositório do installer (`kryonix-installer`).
- Abrir PR no repositório principal (`kryonix`), mencionando a dependência do anterior.
- Iniciar testes End-To-End com uma VM real pelo NixOS Rebuild.
