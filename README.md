# FEEL — Uma viagem em três atos

Protótipo de aventura narrativa em terceira pessoa para **Godot 4.3+**, em GDScript. Não exige plugins, assets externos nem etapas de build.

## Executar

1. Importe `project.godot` no Godot 4.3 ou posterior.
2. Pressione **F6** para testar uma cena aberta ou **F5** para iniciar na ilha.
3. Aproxime-se dos objetos e mire no centro deles até aparecer a instrução de interação.

| Controle | Ação |
| --- | --- |
| WASD / setas | Movimento relativo à câmera |
| Mouse | Câmera orbital |
| E / Enter / Espaço | Interagir |
| Esc | Liberar cursor |
| Clique | Capturar cursor novamente |

**Percurso:** porta da ilha → três fragmentos luminosos na floresta → chave no pedestal central → porta ao fundo → poltrona dourada no corredor central → sessão final.

## Organização

- `scenes/Player.tscn`: personagem reutilizável, colisão, câmera e raycast.
- `scenes/DoorPortal.tscn`: porta reutilizável com dobradiça, moldura, área e luz.
- `scenes/Act1_Island.tscn`, `Act2_Forest.tscn`, `Act3_Cinema.tscn`: entradas de cada ato.
- `scripts/PlayerController.gd`: locomoção, órbita, detecção e sinal `interacted(target)`.
- `scripts/InteractiveDoor.gd`: animação e destino exportado `target_scene`.
- `scripts/CollectiblePiece.gd`: flutuação, rotação, som e coleta única.
- `scripts/ForestPuzzleManager.gd`: progressão e revelação da chave.
- `scripts/CinemaSeat.gd`: bloqueio dos controles, câmera e apagamento das luzes.
- `scripts/CinemaScreen.gd`: projeção de vídeo e mensagem final.
- `scripts/GameFlow.gd`: autoload de HUD, progresso e fades.
- `scripts/WorldBuilder.gd`: cenários procedurais de demonstração.
- `docs/SDD.md`: decisões técnicas e escopo.

## Inserir o vídeo final

Coloque um vídeo **Ogg Theora `.ogv`** em `assets/video/`. Abra `Act3_Cinema.tscn`, selecione a raiz e atribua o recurso ao campo **Cinema Video** no Inspector. Edite **Final Message** para personalizar o encerramento. O `WorldBuilder` transmite esses campos ao `CinemaScreen`.

O vídeo é reproduzido por `VideoStreamPlayer` em um `SubViewport` 1280×720, cuja textura ocupa a tela física do cinema. Utilize vídeo 16:9. Sem um recurso configurado, uma cartela animada substitui o vídeo para permitir testar todo o fluxo; ela não é um vídeo incluído no projeto.

## Árvore do jogador

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── Visual (Node3D)
│   ├── Body (MeshInstance3D)
│   └── Nose (MeshInstance3D)
└── CameraPivot (Node3D)
    └── SpringArm3D
        └── Camera3D
            └── InteractionRay (RayCast3D)
```

A camada 1 é `World`; a camada 2 é `Interactable`. O raycast da câmera testa ambas para respeitar obstáculos, mas só permite interação com objetos que implementem `interact(player)` e `get_prompt()`, a menos de quatro metros do jogador. O braço testa somente o mundo e exclui o corpo do jogador. O sinal `interacted(target)` é emitido antes da chamada ao objeto; não conecte uma segunda execução da mesma interação ao sinal.

## Validação

Com Godot no PATH:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/smoke.gd
```

O smoke test instancia os três atos, verifica a coleta, bloqueio da porta, chave, estado da sessão e encerramento de demonstração. Uma segunda opção, sem Godot, verifica referências e sintaxe:

```sh
python3 tests/check_project.py
# Opcional, em ambiente virtual: pip install gdtoolkit==4.3.4
gdparse scripts/*.gd tests/smoke.gd
```

A inspeção visual, colisões, enquadramentos e reprodução de um `.ogv` real ainda devem ser testados no editor. O protótipo não implementa controles mobile, salvamento, menus ou assets de alta fidelidade.
