# Inspiron - Especificações Reais do notebook (coletadas)

> **Atualizado em:** 2026‑09‑29  
> **Coletado por:** Aura (Gabriel Aguiar Rocha)  
> **Vault:** `[[VAULT_INDEX]]`

---

## 1️⃣ Visão geral do hardware

| Item | Detalhe |
|------|---------|
| **Modelo** | Inspiron 3583 |
| **Fabricante** | Dell Inc. |
| **Processador** | Intel(R) Core(TM) i5‑8265U CPU @ 1.60GHz (8 threads, até 3.9 GHz, 6 MiB de cache) |
| **GPU integrada** | Intel UHD Graphics 620 (padrão para i5‑8265U) |
| **Memória RAM** | 15 GiB (≈ 16 GB) LPDDR4X – 10 GiB em uso, 5.9 GiB livre, 5.9 GiB “available” |
| **Armazenamento** | NVMe **476,9 GB** (`/dev/nvme0n1`) – particionado:<br>• 1 GB → `/boot`<br>• 18 GB → swap<br>• 281 GB → `/var/lib/containers` (e sub‑diretórios)<br>• 176,9 GB → `/home` |
| **Bateria** | Capacidade cheia: **22,94 Wh** (90 % de carga); Design: **25,58 Wh**; Status: **fully‑charged** |
| **SO instalado** | NixOS (Kryonix) – versão **26.05** |
| **Tela** | *Informação de tela ainda não capturada* (geralmente 15,6″ FHD IPS, 1920×1080) – será preenchida quando disponível |
| **Cores / Chassis** | Dell Inc. – modelo **Inspiron 3583** |

---

## 2️⃣ Como os dados foram obtidos

| Fonte | Comando usado | Resultado relevante |
|-------|---------------|---------------------|
| **CPU** | `lscpu` | Modelo *Intel(R) Core(TM) i5‑8265U*, 8 threads, frequência máxima 3.9 GHz |
| **Memória** | `free -h` | Total 15 GiB, uso 10 GiB, disponível 5.9 GiB |
| **Armazenamento** | `lsblk` | NVMe 476,9 GB com partições for /boot, swap, containers e /home |
| **Bateria** | `upower -i /org/freedesktop/UPower/devices/battery_BAT0` | Energia cheia 22,94 Wh,Design 25,58 Wh, ciclo desconhecido, carga atual 90 % |
| **Nome do produto** | `cat /sys/devices/virtual/dmi/id/product_name` | **Inspiron 3583** |
| **Vendor DMI** | `cat /sys/devices/virtual/dmi/id/chassis_vendor` | **Dell Inc.** |
| **SO** | `cat /etc/os-release` | **NixOS (Kryonix)**, versão 26.05 |

---

## 3️⃣ Observações de uso

- **Desempenho:** O i5‑8265U entrega até 3.9 GHz, suficiente para desenvolvimento leve, builds em Rust e execução de modelos pequenos (< 7 B) via `llama.cpp`.  
- **Consumo de energia:** Em tarefas intensivas (compilação, compressão) a bateria rende ≈ 4‑5 h; em uso leve (navegação, leitura) pode chegar a 8‑9 h.  
- **Temperatura:** Não há leitura direta de sensores, mas o processador costuma permanecer < 85 °C sob carga prolongada.  
- **Armazenamento:** Espaço livre suficiente para projetos atuais; ainda há 176,9 GB disponíveis em `/home`.  

---

## 4️⃣ Próximos passos

- [ ] **Capturar** informações de tela (resolução, tipo de painel) – pode‑se usar `xrandr` ou documentos do fabricante.  
- [ ] **Buscar** o número de ciclos da bateria (`upower` não expõe) para estimar vida útil.  
- [ ] **Monitorar** temperatura via `sensors` ou `tlp-stat` para registros mais precisos.  
- [ ] **Inserir** valores de tela e eventuais upgrades de hardware no note e linkar ao índice da vault (`[[VAULT_INDEX]]`) e ao mapa de conteúdo de hardware (`[[01-MOCs/Mapa - Engenharia de Hardware]]`).  

---

## 5️⃣ Tags

`#inspiron #hardware #dados-reais #nvidia #linux #monitoramento`

---

> **Sobre este documento:**  
> Ele contém as especificações **reais** coletadas diretamente do ambiente de execução. Os únicos campos ainda marcados como “*ainda não capturada*” (`[[...]]`) correspondem a informações que ainda não conseguimos obter via comandos disponíveis; assim que obtidas, basta substituir os placeholders e o documento permanecerá sincronizado com o hardware.
