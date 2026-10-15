# SDD — FEEL

## Visão e escopo

Walking simulator / aventura narrativa linear, terceira pessoa, puzzle leve. Três espaços marcam descoberta, reconstrução e contemplação. Esta entrega é um **protótipo funcional com arte placeholder**, não uma produção de fidelidade final.

Godot 4.3+, renderizador **Compatibility**: reduz exigências de hardware e preserva uma base para exportação web. A seleção não significa que a exportação mobile/web esteja testada. Volumetric Fog, God Rays volumétricos e reflexos de alta fidelidade não estão implementados; exigiriam uma variante Forward+ e revisão de desempenho.

## Atos e condições

| Ato | Representação atual | Condição de saída |
| --- | --- | --- |
| Ilha | Areia, palmeiras geométricas, água animada por shader e sol quente | Interagir com a porta |
| Floresta | Árvores estilizadas, caminho, fragmentos emissivos, pedestal e porta | Coletar os três fragmentos, depois a chave, e interagir com a porta |
| Cinema | Paredes, poltronas, corredor, iluminação quente e tela física | Sentar na poltrona destacada; vídeo ou cartela; mensagem final |

Os cenários são gerados por `WorldBuilder` com distribuição determinística das árvores. Barreiras impedem sair do terreno. A porta é uma área de interação, não uma barreira física; a transição só ocorre pela interação autorizada.

## Contratos e estado

- Objetos interativos: `Area3D`, camada 2, `get_prompt() -> String`, `interact(player)`.
- Jogador: velocidade cinco metros/segundo, gravidade, movimento relativo à órbita, rotação visual suavizada, sem salto.
- `GameFlow`: UI persistente, contagem, posse da chave e exclusão mútua durante fades. Erros de mudança de cena restauram a tela e exibem aviso.
- `CollectiblePiece`: guarda contra coleta repetida, emite `collected(is_key)`, toca um sino sintetizado e usa `queue_free()`.
- `ForestPuzzleManager`: reinicia o puzzle ao entrar na floresta, revela uma única chave ao completar a contagem e só concede acesso após coletá-la.
- `InteractiveDoor`: guarda contra acionamentos concorrentes, gira a dobradiça e solicita fade/transição. Destino e exigência de chave configuráveis no Inspector.
- `CinemaSeat`: interação única; bloqueia controles e interpola a câmera até o enquadramento da tela enquanto as luzes apagam.
- `CinemaScreen`: vídeo Theora nativo, conexão ao sinal `finished` e mensagem com fade. Sem vídeo, usa sequência substituta claramente identificada.

## Assets e evolução visual

Substituir malhas procedurais por cenas `.glb` licenciadas. Kenney é uma opção para kits CC0; verificar a licença individual de recursos do Sketchfab, Poly Pizza ou Fab antes de redistribuir. Não há assets dessas bibliotecas incluídos aqui. `.uasset` não é um formato de importação Godot; prefira GLTF/GLB ou conversão autorizada via Blender.

Próximos passos: arte e áudio ambiente, animação do personagem, opções de acessibilidade, controles de toque/analógico, menus, performance e testes de exportação. Nenhuma mídia pessoal foi adicionada ao cinema.
