# Project Verification Config

This file holds project-specific overrides to the default verification methodology. If a value is not set here, the default from `_meta/PROMPT.md` applies.

## Mode overrides

### Coverage thresholds

Override per-mode coverage thresholds for this project. Defaults are in `_meta/PROMPT.md`.

- Spike: n/a
- Product: 80
- Infrastructure: 90

### Eval requirements

- Spike: optional
- Product: required
- Infrastructure: required

### Coverage of irreversible surfaces

For state-mutating, irreversible code paths, the coverage floor is 100% in every mode. Override only with explicit justification.

- Override: none
- Justification: n/a

## Project-specific scorecard axes

If this project has axes beyond the default set, add them here.

- (none defined)

## Project-specific escalation rules

Additional triggers for human review beyond the defaults.

- (none defined)

## Notes

<Free-form notes about this project's verification posture, peculiarities, or open methodological questions.>
