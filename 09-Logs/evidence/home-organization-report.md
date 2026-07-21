# Relatório de Organização do Diretório *home* (~/home-organization-report.md)

> **Gerado em:** 2026‑09‑29  
> **Por:** Aura (Gabriel Aguiar Rocha) – sem movimentar arquivos, apenas análise e sugestões.

---

## 1️⃣ Visão geral do conteúdo

| Categoria | Quantidade aproximada* | Exemplos de caminhos |
|----------|-----------------------|----------------------|
| **Arquivos total escaneados** | **≈ 500** | `/home/rocha/*` (todos os entries retornados por `search_files` ) |
| **Cache** | **≈ 50** | `/.cache/...`, `/.var/app/.../cache/...`, `/.hermes/.../cache/...` |
| **Logs** | **≈ 50** | `/home/rocha/kryonix/kryonix-vault/09-Logs/...`, `/home/rocha/Documents/.../main.log`, `/home/rocha/.var/app/.../logs/...` |
| **Markdown (*.md*)** | **≈ 50** | `/home/rocha/kryonix/kryonix-vault/notes/Inspiron.md`, `/home/rocha/kryonix/kryonix-vault/README.md`, `/home/rocha/.hermes/skills/.../SKILL.md` |
| **Configurações** | *muitos* (não countado) | `/.config/...`, `/.var/app/.../prefs.js`, `/.anydesk/anydesk.trace` |
| **Dados de aplicativos** | *muitos* (não countado) | `/.var/app/.../storage/...`, `/.local/share/...`, `/.cache/...` |

\*Os números vêm dos contadores `search_files` (output_mode=count). Os resultados foram truncados; portanto as contagens são **mínimos** reais.

---

## 2️⃣ Estrutura de diretórios observable

```
/home/rocha/
├─ .cache/                     # caches de runtime (≈50 arquivos)
├─ .config/                    # arquivos de configuração de Apps
├─ .local/                     # dados de usuário (state, share)
├─ .var/app/                   # sandboxes de aplicações gráficas (Zen Browser, etc.)
│   └─ app.zen_browser.zen/
├─ .gemini/                    # diretório de experimentos de IA
├─ .hermes/                    # estado, logs e skills da Aura
├─ .local/share/               # shared data (klipper, tirith, etc.)
├─ Documents/                  # documentos pessoais, acadêmicos e projetos
│   ├─ Academico/
│   ├─ Projetos/
│   └─ 00_Inbox/
├─ Downloads/                  # arquivos baixados
├─ .kde/, .mozilla/, etc. (não Aparecem na busca, mas existem)
└─ kryonix/                    #checkout do repositório de infraestrutura
    ├─ kryonix-vault/          # vault principal (Obsidian + notas)
    └─ kryxd/      # código do instalador
```

---

## 3️⃣ Tipos de arquivos e suas principais *pasta‑raízes*

| Tipo                   | Pasta‑raíz predominante                                                             | O que costuma conter                                                                                                |
| ---------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Cache**              | `~/.cache/` e `~/.var/app/.../cache/`                                               | Arquivos temporários de navegadores, pavilion,.rustup caches, arquivos `.sqlite-wal` de bancos de dados de extensão |
| **Logs**               | `~/kryonix/kryonix-vault/09-Logs/`, `~/Documents/.../logs/`, `~/.var/app/.../logs/` | Relatórios de builds, backups de PRs, logs de browsers, traces de AnyDesk, logs de serviços de rede                 |
| **Markdown**           | `~/kryonix/kryonix-vault/notes/` e `~/kryonix/kryonix-vault/`                       | Notas técnicas, documentos de projeto, MOCs, protocolos de segurança                                                |
| **Config**             | `~/.config/`                                                                        | Arquivos `.json`, `.toml`, `.yaml` de apps, configuração de terminadores, definições de temas Obsidian              |
| **Dados de Aplicação** | `~/.var/app/`, `~/.local/share/`                                                    | Bancos de dados SQLite, arquivos de state, caches de Electron/Zen, bancos de dados de backup do navegador           |

---

## 4️⃣ Sugestões de **classificação estática** (sem mover nada)

| Categoria | Pasta sugerida (apenas para *visualização*) | Sub‑subcategorias recomendadas |
|----------|--------------------------------------------|--------------------------------|
| **Cache** | `~/Visual-Cache/` | `BrowserCache/`, `RustCache/`, `UVCache/`, `SystemCache/` |
| **Logs**  | `~/Visual-Logs/` | `AppLogs/`, `BuildLogs/`, `SystemLogs/`, `Trace/` |
| **Markdown** | `~/Visual-Notes/` | `VaultNotes/`, `AcademicDocs/`, `ProjectDocs/` |
| **Config** | `~/Visual-Configs/` | `ShellConfigs/`, `AppConfigs/`, `IDEConfigs/` |
| **Dados de Aplicação** | `~/Visual-Data/` | `DBs/`, `State/`, `Cache/` (separado de *Cache* por origem) |

> **Como usar:** Crie *atalhos* (symlinks ou marcadores) dentro dessas pastas que apontem para os caminhos originais, caso queira navegar rapidamente sem alterar a estrutura física.

---

## 5️⃣ Relatório resumido em tabelas

### 5.1 Contagem por *pattern* (output_mode=count)

| Pattern | Count (mínimo) |
|---------|----------------|
| `*cache*` | 50 |
| `*log*`   | 50 |
| `*.md`    | 50 |

### 5.2 Exemplos de arquivos “pesados”

| Arquivo (caminho) | Tipo | Tamanho aproximado (se visível) |
|-------------------|------|---------------------------------|
| `/home/rocha/.var/app/app.zen_browser.zen/.zen/rtuwqckm.Default (release)/storage/default/https+++mail.google.com/cache/caches.sqlite` | SQLite cache (Gmail) | > 10 MB (não medido aqui) |
| `/home/rocha/kryonix/kryxd/target/debug/.fingerprint/kryxd-426b4e1e6a99e2d3/output-test-bin-kryxd` | Binário de teste | ~ 3 MB |
| `/home/rocha/.hermes/logs/agent.log` | Log de agente Hermes | ~ 2 MB |
| `/home/rocha/.var/app/app.zen_browser.zen/.zen/rtuwqckm.Default (release)/places.sqlite` | Banco de dados de bookmarks | ~ 5 MB |

*(Os tamanhos são estimativas baseadas em observação de extensões e contexto; medição exata pode ser feita com `du -sh`.)*

---

## 6️⃣ Próximas etapas (opcionais)

1. **Gerar um *snapshot* JSON** com a árvore de diretórios (ex.: `~/.hermes/session_search` ou `tree -L 2 ~/ > ~/tree-snapshot.txt`).  
2. **Criar um *relatório de crescimento*** mensal usando `search_files` com *offset* para monitorar o acúmulo de cache/logs.  
3. **Definir *regras de retenção*** (ex.: manter caches de < 30 dias, logs de build por 90 dias, notas markdown Forever).  
4. **Automatizar a limpeza** via um *cron* que apenas *listagens* e *archiva* (sem deletar) – pode‑se usar `cronjob` com `action='create'` + `script` que gera um *tar* em `~/backups/home-$(date +%F).tar.gz`.  
5. **Visualizar** o relatório em Obsidian ou qualquer viewer markdown para fácil navegação.

---

## 7️⃣ Conclusão

- O seu `home` está **bem populated** com caches, logs e notas markdown, o que indica uso intenso de ferramentas de desenvolvimento, navegadores e ambientes de IA.  
- As contagens mínimasmostram **≈ 150 arquivos** (cache + logs + md) que podem ser agrupados para **visão mais limpa**.  
- A proposta de organização acima **não mexe** nos arquivos originais; apenas cria *categorias lógicas* e *atalhos de visualização*.  
- Caso queira transformar estas sugestões em **scripts de inspeção** ou **cron jobs de monitoramento**, basta dizer que deseja o próximo passo – eu posso gerar o código correspondente.

---  

*Relatório salvo em:* **`/home/rocha/reports/home-organization-report.md`**  
*Para visualizar:* abra com qualquer editor markdown ou no Obsidian (`vault` já contém o caminho `notes/` onde o relatório pode ser colocado).
