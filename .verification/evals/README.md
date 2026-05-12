# Evals folder

This folder holds evaluation baselines and versioned results for non-deterministic surfaces in the project.

Examples of non-deterministic surfaces:
- LLM-generated content (descriptions, summaries, classifications)
- Ranking or recommendation algorithms
- Fuzzy matching or similarity scoring
- Anything where "correctness" is judged by a rubric rather than a strict equality check

## Structure

Each non-deterministic surface gets its own subfolder:

```
evals/
├── <surface-name>/
│   ├── README.md          ← what's evaluated, how, by whom
│   ├── baseline.md        ← current baseline scores and ship thresholds
│   ├── v1-results.json    ← versioned results
│   ├── v2-results.json
│   └── ...
└── <another-surface>/
    └── ...
```

See `_meta/SCHEMA.md` for the full format spec.

## When to add an eval folder

Add one whenever you create or modify a non-deterministic surface that has a corresponding contract scored `med` criticality or higher.

In `product` and `infrastructure` modes, evals are required for these surfaces. In `spike` mode, evals are optional but encouraged because they make mode promotion easier.

## Empty for now

This folder is empty in the template. Add subfolders as the project develops.
