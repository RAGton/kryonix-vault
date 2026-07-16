# SDDM

Temas e wiring do display manager do cliente NODE.

- `node-control/`: tema canônico dark do cliente NODE, com card sólido e foco em operação.
- `node-sugar-light/`: legado mantido apenas como referência histórica de transição.
- `sddm.nix`: módulo NixOS que injeta o tema no sistema de forma declarativa.

Regra:

- preferir tema próprio quando o upstream não sustenta a linguagem visual do produto;
- evitar drift entre assets, wiring e captura do BrandLab;
- manter assets de branding dentro desta árvore.
