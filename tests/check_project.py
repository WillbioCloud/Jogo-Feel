"""Dependency-free resource-reference checks; not a substitute for Godot."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
errors = []
for path in [ROOT / 'project.godot', *ROOT.glob('scenes/*.tscn'), *ROOT.glob('scripts/*.gd')]:
    text = path.read_text()
    for resource in re.findall(r'res://[^"\s)]+', text):
        if not (ROOT / resource.removeprefix('res://')).exists():
            errors.append(f'{path.name}: missing {resource}')
assert not errors, '\n'.join(errors)
assert 'layer_2="Interactable"' in (ROOT / 'project.godot').read_text()
assert len(list(ROOT.glob('scenes/Act*.tscn'))) == 3
print('PASS: resource references, three acts, and interaction layer')
