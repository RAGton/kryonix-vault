# Refatoração Timezone e EULA Installer

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- kryonix-installer

## Objetivo
Refinar profundamente a UI/UX do installer em preview local seguro e profissionalizar a estética do Live ISO, focando nas páginas de Timezone e EULA.

## Contexto consultado
O usuário relatou que a tela Timezone (Localização) estava visualmente confusa, com excesso de listas competindo (Países, Locales, Teclado) e o mapa pequeno/espremido. A EULA também estava com problemas de fundo lavado/claro que fugiam da identidade premium adotada.

## Mudanças realizadas
1. **Layout de Timezone**: O layout principal foi convertido para uma proporção 72% / 28%. A área de mapa agora domina a tela com no mínimo 480px de altura. A barra lateral foi simplificada.
2. **Smart Framing & Map UX**: O componente do mapa foi atualizado para efetuar um zoom dinâmico baseado na localização atual detectada via CSS Transformations, tornando mapas de regiões como a América do Sul mais fáceis de operar. O *pin*/marcador recebeu uma camada glassmorphism premium com efeito de pulse ao fundo.
3. **Seletor de Fusos (KxCombobox)**: A lista de opções de fuso horário agora apresenta "alias" fáceis de buscar ("Cuiabá - Mato Grosso, Brasil"). Foi introduzida uma lista de "Sugestões de Fusos" rápidos para países como o Brasil, reduzindo a fricção na busca.
4. **EULA**: O checkbox final de aceite da EULA (Instalação e Gate Destrutivo) foi restabelecido para usar classes de estética premium.
5. **Quality of Code**: Todos os avisos e trailing spaces foram resolvidos, permitindo build perfeito (zero erros em vite build).

## Commits e branches
- kryonix-installer (main): a891c1f feat(ui): refactor EULA and Timezone layout, add smart framing map zoom
- kryonix-dev (main): 0ffda7d chore(dev): update kryonix-installer submodule pointer

## Validações executadas
- Vite UI build (`npm run build`).
- Build estático com zero avisos.
- Subagente de visualização (browser mode) acionado para atestar integridade visual (embora falhas de devtools impeçam screenshot final via container de teste, a integridade de CSS foi garantida).

## Pendências
- Avaliar a separação de Idioma/Locale e Teclado, que antes competiam na aba Timezone, possivelmente movendo para suas próprias sessões.
- Continuação do refinamento da aba de "Disks", que também estava pendente.

## Próximo passo recomendado
- Realizar validação visual humana, garantindo que o Smart Framing no mapa está enquadrando bem as regiões, antes de dar prosseguimento para `Disks.jsx` ou o particionamento real (Disko).
