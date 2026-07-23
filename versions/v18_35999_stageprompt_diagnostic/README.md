# Task22 v18: Original 35999 Stage-Prompt Capability Diagnostic

v18 is a diagnostic-only control for the original `35999` VLA under the
repaired latest Task22 remote scorer. It does **not** count as VLM-autonomous
success.

## Purpose

Determine whether the policy can physically complete each Task22 primitive
when it receives the correct prompt. The controller advances only after a real
remote stage check succeeds:

`pick tomato -> pour first -> pour second -> place tomato aside -> open microwave`

For cookies, it uses only an EEF-distance check at the recorded `pick cookies`
target before changing to `place cookies`. No object is moved or synthesized.

## Boundaries

- The original `35999` checkpoint and its built-in norm asset are retained.
- The repaired remote stage scorer is retained and still decides success.
- No object anchor, goal override, completed-task VLM field, or fake stage is
  used.
- Prompts are program-scheduled in this diagnostic, so any success only proves
  VLA action capability. A later VLM-owned partial-rescue version must earn
  autonomous prompt credit separately.
