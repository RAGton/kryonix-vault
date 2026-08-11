---
card_id: t_eb10dca9
status: scheduled
type: 
priority: 3
created_at: 2026-08-06T00:33:08+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T19:38:07.030707+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# [tech-debt][kryonix] xdg.mimeApps motor vs user config (80+ vs 5 associacoes)

**Card:** `t_eb10dca9` | **Status:** `scheduled`

## Descrição

## Origem
Descoberto durante fix do t_03e3dfb6 (clobber-protection do home-manager).

## Sintoma
- `repos/kryonix/desktop/hyprland/core/mime.nix:49` declara `xdg.mimeApps` com 80+ associacoes MIME (image/, video/, audio/, pdf, text, web, archive, office).
- `repos/kryonixos/users/rocha/inspiron/default.nix:307` declara `xdg.mimeApps` com 5 associacoes (zen-browser pra html/xml/http/https/xhtml).
- User config (kryonixos) sobrepoe o motor (kryonix) por causa de ordem de import. Resultado: KDE/Dolphin perdem 75+ associacoes de MIME types.

## Hipotese
`lib.mkIf` no motor (conditionline: `config.wayland.windowManager.hyprland.enable or false`) pode ou NAO estar sobrescrevendo o user config dependendo da condicional. Precisa validar.

## Proximo passo
1. Ler documentacao do home-manager sobre merge de xdg.mimeApps entre modulos
2. Testar eval: `nix eval .#nixosConfigurations.inspiron.config.home-manager.users.rocha.xdg.mimeApps` para ver o que efetivamente eh gerado
3. Decidir estrategia de fix:
   - Remover bloco redundante do user config (deixar so o motor)
   - OU: refatorar motor para que user config possa adicionar sem sobrescrever
   - OU: usar lib.mkMerge para combinar associacoes

## Nao-objetivos
- NAO relacionado ao t_03e3dfb6 (que ja tem fix via force = true)
- NAO trocar de KDE (decisao arquitetural)
- NAO mexer no motor Hyprland (coexistencia com KDE)

## Esforco estimado
4-8 horas de investigacao + 1-2 horas de fix.

## Bloqueia
Nenhum sistema. E tech debt latente.

## Assignment

- **Criado por:** `aura`
- **Assignee:** `default`

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T19:38:07.030711+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._