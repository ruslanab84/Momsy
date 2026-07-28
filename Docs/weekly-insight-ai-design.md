# Weekly Insight AI design

## Goals

- Explain the baby's logged sleep using the full age-specific WHO 24-hour range.
- State whether the logged average is below, inside, or above that range and by how much.
- Explain feeding data without presenting an app reminder heuristic as a WHO clinical target.
- Keep recommendations age-safe, especially before 6 months and when reactions are flagged.
- Produce enough structured content for a clear parent-facing report.

## Gemini output contract

Firebase AI Logic structured output is used with `application/json` and a response schema. Each report section is returned as an array of complete sentences with enforced minimum and maximum item counts. The app validates the array depth and joins the sentences into readable paragraphs for the existing persisted model.

## Evidence boundaries

- WHO sleep ranges include naps and are selected deterministically by age in the app.
- For milk feeding, WHO recommends responsive/on-demand breastfeeding rather than one universal feed count. The current interval/count value in Momsy is explicitly labelled as an app reminder heuristic.
- WHO complementary-meal frequency is included for 6–23 months, but the current new-food diary is not a complete meal log, so the report does not classify meal frequency as low or normal.
- Diaper totals alone are not used to infer hydration or intake adequacy.
- Reports are informational and never diagnostic.

## Source references

- Firebase AI Logic: structured output using response schemas.
- WHO: 24-hour sleep recommendations for children under 5.
- WHO: infant and young child feeding guidance.
- Apple SwiftUI: multiline Text layout and Dynamic Type-compatible rendering.
