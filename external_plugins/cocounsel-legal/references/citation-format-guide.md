# Citation Format Guide

*Reference for citation formatting in research-brief and research-export skills. This file documents the supported formats — the user's configured preference is in their research profile.*

## Supported formats

### 1. Bluebook (default)

The Bluebook: A Uniform System of Citation (21st ed.). Standard for most federal courts, law reviews, and many state courts.

**Case citations:**
```
Smith v. Jones, 123 F.3d 456, 460 (9th Cir. 2020).
```

**With parenthetical:**
```
Smith v. Jones, 123 F.3d 456, 460 (9th Cir. 2020) (holding that
non-compete agreements for executive employees are enforceable where
the restriction is reasonable in scope and duration).
```

**Signals:**
| Signal | Meaning |
|---|---|
| *See* | Cited authority directly supports the proposition |
| *See also* | Additional authority supports; follows a primary cite |
| *Cf.* | Cited authority supports by analogy |
| *But see* | Cited authority contradicts the proposition |
| *Contra* | Cited authority directly contradicts |
| *See generally* | Background or general support |

**Subsequent history:**
```
Smith v. Jones, 123 F.3d 456 (9th Cir. 2020), aff'd, 456 U.S. 789 (2021).
Smith v. Jones, 123 F.3d 456 (9th Cir. 2020), rev'd, 456 U.S. 789 (2021).
Smith v. Jones, 123 F.3d 456 (9th Cir. 2020), cert. denied, 456 U.S. 789 (2021).
```

**Statutes:**
```
Cal. Bus. & Prof. Code § 16600 (West 2024).
28 U.S.C. § 1332 (2018).
```

### 2. ALWD

ALWD Guide to Legal Citation (7th ed.). Required by some law schools and state courts.

**Key differences from Bluebook:**
- No large-and-small caps for authors in books/articles
- "Id." always italicized (not in regular type)
- Periodical abbreviations may differ slightly
- Generally simpler formatting rules

**Case citations (same as Bluebook for most purposes):**
```
Smith v. Jones, 123 F.3d 456, 460 (9th Cir. 2020).
```

### 3. Firm house style

Custom deviations from Bluebook. When the user configures `firm-house-style`, the research profile's `House citation style notes` section captures the specific deviations. Common deviations:

| Deviation | Example |
|---|---|
| No Oxford comma in case names | "Smith, Jones and Doe" not "Smith, Jones, and Doe" |
| Pin cites always include page range | "456, 460-62" not "456, 460" |
| No parallel citations | Omit state reporter when official reporter cited |
| Short form after first cite | "Smith, 123 F.3d at 460" |
| Omit "cert. denied" unless relevant | Drop unless certiorari is part of the argument |

When applying house style, preserve the original Bluebook citation in a footnote if the conversion is uncertain: `[original: 123 F.3d 456]`.

## Source attribution tags

Every citation in a skill output should carry a provenance tag:

| Tag | Meaning |
|---|---|
| `[from research report]` | Citation found in the Deep Research output |
| `[from follow-up query]` | Citation from a second Deep Research run |
| `[Westlaw verified]` | Citation status confirmed via MCP query |
| `[model knowledge — verify]` | Non-citation context only; never for case cites |
| `[CITE NEEDED]` | Proposition needs authority; not yet found |
| `[unresolved — verify manually]` | Citation could not be verified via MCP |

## Treatment status indicators

Used in citation-verification results:

| Status | Meaning | Display |
|---|---|---|
| `good_law` | No negative treatment found | Green / no flag |
| `caution` | Some negative treatment, but not overruled | Yellow flag |
| `negative` | Overruled, reversed, or superseded | Red flag + `[review]` |
| `unresolved` | Could not verify via Westlaw | Gray + manual check needed |
