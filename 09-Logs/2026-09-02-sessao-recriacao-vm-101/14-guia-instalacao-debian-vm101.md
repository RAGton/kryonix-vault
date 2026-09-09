# Guia de Instalação Debian — VM 101 (aura)

Data: 2026-09-02
Agente: Aura (MiniMax-M3)
Host destino: glacier (10.1.1.2)
VM ID: 101 (aura)
Recurso: https://168.227.125.70:28006 → Proxmox web

## Pré-requisitos

Você deve ter acesso ao Proxmox web via:
- URL: `https://168.227.125.70:28006`
- Usuário: `rocha@pam`
- Senha + TOTP

## Navegação até o console da VM 101

1. Abra `https://168.227.125.70:28006` no navegador
2. Login com `rocha@pam` + senha + TOTP
3. Se aparecer erro de certificado SSL, clique "Avançado" → "Prosseguir"
4. Menu lateral esquerdo → clique em `glacier` (o host)
5. Lista de VMs aparece
6. Clique em **VM 101 ("aura")**
7. Menu da VM → clique em **"Console"** (canto superior direito)
8. Selecione **SPICE** (mais rápido) ou **noVNC**

## Instalação do Debian (passo a passo)

### Tela 1 — Idioma
- Selecione: **English** (recomendado) ou **Português (Brasil)**
- Tab até "Continue" → Enter

### Tela 2 — País
- Selecione: **Brazil**
- Continue

### Tela 3 — Teclado
- **Brazilian (ABNT2)** ou American English
- Continue

### Tela 4 — Hostname
- Digite exatamente: `aura` (tudo minúsculo)
- Continue

### Tela 5 — Domínio
- Deixe VAZIO
- Continue

### Tela 6 — Senha do root
- Digite: `Rag200520@.` (com ponto final)
- Confirme: `Rag200520@.`
- Continue

### Tela 7 — Nome completo do usuário
- `Gabriel`
- Continue

### Tela 8 — Username
- `gabriel` ou `rocha`
- Continue

### Tela 9 — Senha do usuário
- `Rag200520@.` (mesma senha)
- Continue

### Tela 10 — Particionamento
- **Guided - use entire disk**
- Selecione o disco (VIRTIO - 64GB)
- **All files in one partition** (recomendado para VM)
- **Finish partitioning and write changes to disk**
- **Yes** (escrever mudanças)
- Espere 1-3min

### Tela 11 — Configuração do APT
- País: **Brazil**
- Mirror: **deb.debian.org** ou **ftp.br.debian.org**
- Proxy: vazio
- Espere 2-5min

### Tela 12 — Popularity contest
- **No**

### Tela 13 — Seleção de software
- Desmarque GNOME (não precisa)
- Mantenha **SSH server** ✓
- Mantenha **standard system utilities** ✓
- Continue

### Tela 14 — Instalação do GRUB
- **Yes**
- Device: `/dev/vda` (ou disco principal)
- Continue

### Tela 15 — Instalação completa
- **Continue** (reiniciar VM)
- VM vai reiniciar sozinha

## Pós-instalação

### 1. Login
- Username: `aura`
- Password: `Rag200520@.`

### 2. Verificar rede
```bash
ip a
# deve mostrar 10.1.1.4/24 na interface ens18
```

### 3. Verificar SSH
```bash
systemctl status ssh
# deve estar "active (running)"
```

### 4. Testar conexão SSH
Do Inspiron (glacier):
```bash
ssh -i /home/rocha/.ssh/glacier-access root@10.1.1.4
# ou via LAN: ssh -i ~/.ssh/glacier-access root@10.1.1.4
```

## Próximo passo (após instalação)

Quando você terminar a instalação e logar via SSH no terminal do glacier:

1. Eu vou configurar:
   - NVIDIA driver + CUDA
   - Ollama + DeepSeek Coder 6.7B
   - Hermes Agent com Hindsight SQLite
   - Cloudflare Tunnel re-ativado
   - Backup diário automático

2. Validar tudo:
   - SSH funciona
   - Ollama responde
   - Hermes Agent roda
   - Hindsight persiste memórias
   - Tunnel expõe Hermes via HTTPS

## Troubleshooting

### Tela preta no console
- Aguarde 30s (boot pode estar lento)
- Se continuar, me avisa que eu reinicio a VM

### Erro de TOTP
- Abra o app Authenticator no celular
- Use o código atual de 6 dígitos

### "No bootable device"
- Significa que o ISO não está attached
- Eu verifico e atacho novamente

### VM não inicializa via console
- Use SPICE em vez de noVNC
- Ou instale VNC viewer no seu PC

## Após finalizar

Me avise quando:
- Instalação completou
- Login funcionou
- Rede pegou IP 10.1.1.4
- SSH conecta do Inspiron

Aí eu sigo com a próxima fase automaticamente.
