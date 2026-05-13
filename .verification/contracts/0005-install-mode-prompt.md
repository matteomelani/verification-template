# Contract: Install Mode Prompt

**ID:** 0005
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

The script must prompt the user to choose from exactly the three valid modes (`spike`, `product`, `infrastructure`), reject any other input with a re-prompt or clear error, and write the chosen value as the first non-comment line of `.verification/MODE.md` in the target.

## Why it exists

`MODE.md` controls enforcement level for every future LLM session on the installed project. If the wrong mode is written (or no mode at all), the LLM will silently apply incorrect enforcement — too lax in infrastructure projects, too strict in spikes. The prompt ensures users make a deliberate choice rather than accepting a default that may not match their context.

## Scorecard

- **Criticality:** med
  - *Justification:* A wrong mode causes incorrect enforcement on the target project, but is correctable by editing `MODE.md`
- **LLM confidence:** high
  - *Justification:* Logic is straightforward; the three valid values are enumerated
- **Parallelization value:** low
  - *Justification:* Isolated final step
- **Surface type:** state-mutating
- **Reversibility:** reversible

## Human review

- **Required:** yes
- **Reason:** state-mutating + criticality=med
- **Reviewed by:** matteomelani
- **Reviewed on:** 2026-05-12
- **Outcome:** approved

## Verification

- **Tests:**
  - `test/install_test.sh::test_mode_spike_written` — INSTALL_MODE=spike produces correct MODE.md
  - `test/install_test.sh::test_mode_product_written` — INSTALL_MODE=product produces correct MODE.md
  - `test/install_test.sh::test_mode_infrastructure_written` — INSTALL_MODE=infrastructure produces correct MODE.md
  - `test/install_test.sh::test_mode_invalid_rejected` — invalid input causes re-prompt (tested via expect or INSTALL_MODE override)
- **Evals:** n/a
- **Method:** integration
- **Coverage of this contract:** 100%

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** test that MODE.md first line is exactly the mode string with no leading/trailing whitespace

## Related

- **Depends on:** contracts/0003-install-file-copy-completeness.md
- **Depended on by:** n/a
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: med / high / low / state-mutating / reversible.
