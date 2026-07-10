---
id: clean-coder-kryonix-profissionalismo
title: Clean Coder aplicado ao Kryonix
type: principio-operacional
status: ativo
project: Kryonix
area: engenharia
componentes:
  - agentes
  - commits
  - testes
  - iso
  - nixos
  - installer
  - vault
  - graphify
fonte_verdade: vault
graphify: true
rag: true
confianca: alta
validado_em: 2026-07-10
tags:
  - kryonix
  - engenharia
  - clean-coder
  - profissionalismo
  - qualidade
  - testes
  - agentes
  - graphify
aliases:
  - Clean Coder Kryonix
  - Profissionalismo Técnico Kryonix
  - First Do No Harm
  - Responsabilidade de Engenharia
related:
  - "[[AGENTS]]"
  - "[[OPERATIONS]]"
  - "[[TESTING]]"
  - "[[SECURITY]]"
  - "[[KRYONIX_PROJECT_MEMORY_CURRENT]]"
---

# Clean Coder aplicado ao Kryonix

## Resumo

Esta nota define um princípio permanente para o projeto Kryonix:

> Um agente, desenvolvedor ou operador profissional **não declara algo como pronto sem validação real**.

No Kryonix, profissionalismo técnico significa assumir responsabilidade pelo impacto do código, dizer **não** quando uma decisão coloca o sistema em risco, validar com evidências e preservar a integridade do usuário, do sistema, dos dados e da infraestrutura.

Esta regra se aplica especialmente a:

- NixOS rebuild/switch;
- geração de ISO;
- instalador Kryonix;
- Plasma/KDE desktop;
- SDDM/login;
- rede/libvirt;
- GPU;
- storage/boot;
- automações;
- Graphify;
- Vault;
- agentes autônomos.

---

## Princípio central

```txt
First, do no harm.
```

No contexto do Kryonix:

```txt
Antes de melhorar, não quebrar.
Antes de declarar pronto, validar.
Antes de commitar, revisar.
Antes de aplicar switch, buildar.
Antes de mexer em boot/rede/storage/login, prever rollback.
```

---

## Regras permanentes

### 1. Não declarar sucesso sem evidência

É proibido dizer:

```txt
está pronto
funcionou
corrigido
validado
pode aplicar sem medo
```

sem evidência mínima.

Evidência aceitável inclui:

```txt
comando executado
host
data/hora
resultado
logs relevantes
status PASS/WARN/FAIL
diff revisado
risco conhecido
rollback possível
```

---

### 2. Build não é validação visual

No Kryonix, especialmente em Plasma/KDE/SDDM:

```txt
nixos-rebuild build PASS
```

significa apenas que a configuração compila.

Não significa automaticamente que:

* a UI ficou boa;
* o dock está correto;
* o wallpaper apareceu em todos os monitores;
* o SDDM está utilizável;
* o campo de senha funciona;
* o painel não duplicou;
* o usuário consegue fazer login.

Para UI, o critério é:

```txt
build passa + switch passa + screenshot/log + validação visual real
```

---

### 3. Switch é operação sensível

Antes de sugerir ou executar:

```bash
sudo nixos-rebuild switch --flake .#inspiron
```

deve existir pelo menos:

```bash
nixos-rebuild build --flake .#inspiron
```

e, quando relevante:

```bash
nvd diff /run/current-system ./result || true
```

Nunca aplicar switch automaticamente quando houver risco em:

* boot;
* rede;
* SSH;
* display manager;
* GPU;
* storage;
* libvirt;
* firewall;
* usuário principal;
* sessão gráfica.

---

### 4. Dizer “não” é parte do trabalho

Um agente profissional deve recusar ou pausar quando:

* o plano remove algo que o usuário pediu para fazer funcionar;
* há risco de quebrar login, rede, boot ou dados;
* a solução usa gambiarra quando existe caminho declarativo;
* falta validação;
* o diff está amplo demais;
* há mistura de assuntos no mesmo commit;
* o agente não leu o projeto antes de modificar.

Exemplo:

```txt
Não aprovo remover waywallen/open-wallpaper-engine se o objetivo é fazer wallpaper animado funcionar.
```

---

### 5. Commits pequenos e auditáveis

Regra:

```txt
Um commit deve ter um motivo claro.
```

Evitar:

```bash
git add .
```

Preferir:

```bash
git add caminho/especifico.nix
git commit -m "fix(sddm): improve password field clipping"
```

Commits devem ser separados por domínio:

```txt
desktop(kde)
fix(sddm)
feat(installer)
docs(vault)
chore(dev)
test(installer)
```

Não misturar:

```txt
KDE + SDDM + ISO + Graphify + Vault + libvirt
```

no mesmo commit.

---

## Estratégia de validação

### Validação mínima para NixOS

```bash
cd /home/rocha/kryonix/kryonix-dev/repos/kryonixos

nixos-rebuild build --flake .#inspiron
nvd diff /run/current-system ./result || true
```

### Validação após switch

```bash
readlink -f /run/current-system
systemctl --failed --no-pager
```

### Validação de SDDM

```bash
systemctl status display-manager.service --no-pager -l

journalctl -u display-manager.service -b --no-pager -n 160 | grep -Ei \
  "sddm|kryonix-clean|breeze|astronaut|aurora|qml|error|failed|theme" || true
```

### Validação de Plasma/KDE

```bash
grep -nEi "darwin|pager|icontasks|windowscover|linechart|wallpaperplugin|SlidePaths" \
  ~/.config/plasma-org.kde.plasma.desktop-appletsrc | head -160
```

### Validação multi-monitor

```bash
kscreen-doctor -o

grep -nEi "Containments|lastScreen|screen|wallpaperplugin|SlidePaths|plugin=org.kde.desktopcontainment|plugin=org.kde.panel" \
  ~/.config/plasma-org.kde.plasma.desktop-appletsrc | head -360
```

### Validação de ISO

Uma ISO só pode ser considerada pronta se passar por:

```txt
build da ISO
boot em VM EFI
boot em VM BIOS/Legacy, se suportado
teste com Ventoy, se for requisito
teste do instalador
teste da porta web/API, se aplicável
logs sem erro crítico
```

---

## Política para agentes

Todo agente que atuar no Kryonix deve seguir:

```txt
1. Ler o projeto antes de modificar.
2. Identificar fonte de verdade.
3. Fazer menor mudança correta.
4. Não usar git add .
5. Não remover stack existente sem provar inviabilidade.
6. Validar build.
7. Mostrar diff relevante.
8. Não rodar switch sem aprovação.
9. Registrar riscos.
10. Criar commits pequenos.
11. Explicar rollback.
12. Não declarar pronto sem evidência.
```

---

## Exemplos de decisões corretas

### Caso: SDDM quebrado

Errado:

```txt
Trocar para outro tema externo complexo.
```

Correto:

```txt
Criar kryonix-clean, tema simples, próprio, testável, com campo de senha responsivo e sem dependências QML pesadas.
```

---

### Caso: wallpaper animado não funciona

Errado:

```txt
Remover waywallen/open-wallpaper-engine.
```

Correto:

```txt
Auditar stack, corrigir backend, criar fallback estático/slideshow e ativar de forma declarativa por host.
```

---

### Caso: desktop KDE visual

Errado:

```txt
Reescrever toda a topologia do painel.
```

Correto:

```txt
Preservar top bar + dock aprovados e aplicar polimentos pequenos.
```

---

### Caso: Graphify

Errado:

```txt
Rodar Graphify automaticamente a cada mudança pequena.
```

Correto:

```txt
Rodar Graphify quando solicitado explicitamente ou quando houver mudança arquitetural relevante.
```

---

## Relações para Graphify

```txt
Clean Coder Kryonix -> reforça -> AGENTS.md
Clean Coder Kryonix -> reforça -> TESTING.md
Clean Coder Kryonix -> exige -> evidência antes de declarar pronto
Clean Coder Kryonix -> proíbe -> git add .
Clean Coder Kryonix -> proíbe -> switch automático sem aprovação
Clean Coder Kryonix -> recomenda -> commits pequenos
Clean Coder Kryonix -> recomenda -> rollback planejado
Clean Coder Kryonix -> aplica-se a -> NixOS rebuild
Clean Coder Kryonix -> aplica-se a -> ISO Kryonix
Clean Coder Kryonix -> aplica-se a -> SDDM
Clean Coder Kryonix -> aplica-se a -> Plasma KDE
Clean Coder Kryonix -> aplica-se a -> Graphify
Clean Coder Kryonix -> aplica-se a -> Vault
Clean Coder Kryonix -> aplica-se a -> agentes autônomos
```

---

## Checklist antes de aprovar qualquer tarefa

```txt
[ ] O agente leu os arquivos relevantes?
[ ] A fonte de verdade foi identificada?
[ ] O plano evita quebrar boot/rede/storage/login?
[ ] Existe rollback?
[ ] O diff é pequeno?
[ ] Não foi usado git add .?
[ ] O build passou?
[ ] O switch foi aprovado pelo usuário?
[ ] Há validação pós-switch?
[ ] Há evidência suficiente?
[ ] A conclusão não exagera o que foi realmente testado?
```

---

## Frase canônica

```txt
No Kryonix, profissionalismo é proteger o sistema antes de demonstrar inteligência.
```
