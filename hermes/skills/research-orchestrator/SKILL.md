# Research Orchestrator

Publication-quality research automation with manual oversight and quality gates.

## Overview

This skill produces IEEE/ACM-quality research papers through a structured pipeline:
- Literature review with real citations
- Hypothesis generation with testable predictions
- Analysis and argumentation
- Publication-ready output

## Differences from AutoResearchClaw

| Feature | AutoResearchClaw | Research Orchestrator |
|---------|------------------|----------------------|
| JSON mode | Required (fails with Kimi) | Not required |
| Automation | Fully autonomous | Guided + manual checkpoints |
| Literature | Often irrelevant | Curated by orchestrator |
| Error recovery | Pipeline stops | Graceful degradation |
| Quality | Variable | Review gates at each phase |

## Pipeline Phases

### Phase 1: Literature Foundation
- Search arXiv, IEEE Xplore, Google Scholar
- Extract key papers (20-30 relevant sources)
- Build BibTeX citation database
- **Checkpoint:** Review literature with user

### Phase 2: Hypothesis Framework
- Generate 3 testable hypotheses
- Define measurable predictions
- Identify failure conditions
- **Checkpoint:** Hypothesis approval

### Phase 3: Analysis Design
- Methodology selection
- Data requirements
- Statistical approach
- **Checkpoint:** Methodology review

### Phase 4: Draft Generation
- Full paper structure
- Section-by-section writing
- Citation integration
- **Checkpoint:** Draft review

### Phase 5: Quality Hardening
- Kimi 2.5 Thinking review
- Grok 4.2 adversarial review
- Claude review (if available)
- Final polishing

## Usage

This is a guided workflow, not a CLI tool. Hermes walks through each phase:

1. User provides topic and target venue
2. Hermes runs Phase 1 (literature search via arxiv skill + Semantic Scholar API)
3. User reviews paper list at checkpoint
4. Proceed through phases 2-5 with review at each gate
5. Export final paper

For literature search, use the `arxiv` skill tools:
```python
# arXiv search
import urllib.request, json
url = "http://export.arxiv.org/api/query?search_query=all:grid+optimization&max_results=20"
# Semantic Scholar
url = "https://api.semanticscholar.org/graph/v1/paper/search?query=distribution+grid+optimization&limit=20"
```

## Configuration

```yaml
research:
  model: "kimi-k2.5"
  literature_sources: ["arxiv", "ieee", "semanticscholar"]
  min_papers: 20
  max_papers: 50
  quality_gates: true
  
export:
  format: "ieee"
  template: "ieee-pes"
  figures: true
  tables: true
```

## Quality Standards

- **IEEE PES:** Power engineering focus
- **IEEE Trans:** Full transaction paper structure
- **ACM/IEEE:** Computer science/engineering hybrid

## Adversarial Review Prompts

Included prompts for:
- Kimi 2.5 Thinking (structural)
- Grok 4.2 (contrarian)
- Claude (academic rigor)

## Dependencies

- Kimi API access
- arXiv Python client
- LaTeX distribution (for PDF export)
