# Architecture Types — Multi-Agent Structural Topologies

The architecture type defines how agents are structurally arranged and how authority and information flow between them. Choosing the wrong topology is one of the most expensive architectural mistakes — it shapes every subsequent design decision.

---

## Selection Criteria

Before reviewing the types, answer these questions:

1. **Is the task flow fixed or dynamic?** Fixed → Pipeline or Hierarchical. Dynamic → Supervisor or Market-based.
2. **Are subtasks independent or dependent?** Independent → Parallel. Dependent → Pipeline or Supervisor.
3. **Is output quality or latency the primary constraint?** Quality → Supervisor + Reviewer. Latency → Parallel.
4. **Does the problem benefit from multiple perspectives?** Yes → Debate/Competing.
5. **How large is the agent team?** Small (≤5) → Flat. Large (>5) → Hierarchical or Hybrid.

---

## Type 1 — Pipeline (Sequential)

```
Input ──▶ [Agent A] ──▶ [Agent B] ──▶ [Agent C] ──▶ Output
```

**Description:** Agents form a linear chain. Each agent receives the previous agent's structured output as its input. No orchestrator needed — the sequence is fixed.

**Properties:**
- Deterministic execution order
- Easy to trace, test, and debug (one step at a time)
- Total latency = sum of all step latencies
- One failure blocks the entire pipeline

**Best for:**
- Tasks with a fixed, well-understood sequence of transformations
- Processes that are audited step-by-step (compliance, document processing)
- ETL-style workflows: extract → transform → validate → output

**Avoid when:**
- The sequence of steps is not known upfront
- Some steps could run in parallel and latency matters
- The task is interactive or conversational

**Example:** Resume pipeline — Extract text → Parse entities → Score adherence → Generate questions → Format report

---

## Type 2 — Supervisor (Dynamic Routing)

```
               ┌──▶ [Specialist A] ──┐
User ──▶ [Orchestrator] ──▶ [Specialist B] ──┤──▶ [Orchestrator] ──▶ User
               └──▶ [Specialist C] ──┘
```

**Description:** A central orchestrator receives the input, dynamically decides which specialist(s) to invoke, collects results, and synthesizes a final response. The routing decision is made at runtime based on the input.

**Properties:**
- Flexible: handles diverse input types without code changes
- Single point of control (good for auditing, bad for throughput)
- Orchestrator is the bottleneck and single point of failure
- The orchestrator must know all specialists' capabilities

**Best for:**
- Inputs that vary significantly in type and require different specialists
- Conversational systems where the user's next request is unpredictable
- Systems where domain experts work independently but under a common coordinator

**Avoid when:**
- The routing logic is simple enough to be hardcoded → use a Pipeline instead
- The orchestrator needs to do domain work (boundary violation)
- Throughput is critical and the orchestrator is a bottleneck

**Example:** SIRA recruitment assistant — the orchestrator routes "analyze this resume" to the analysis specialist, "draft an outreach message" to the message specialist, and "summarize pre-interview responses" to the pre-interview specialist.

---

## Type 3 — Parallel + Synthesizer

```
               ┌──▶ [Agent A] ──┐
Input ─────────┤──▶ [Agent B] ──┼──▶ [Synthesizer] ──▶ Output
               └──▶ [Agent C] ──┘
       (all run concurrently)
```

**Description:** Multiple agents receive the same input and run concurrently. Each produces a partial result from its own perspective. A synthesizer agent combines all partial results into a final output.

**Properties:**
- Lowest latency for independent subtasks (parallelism)
- Natural for breadth tasks (multiple angles on the same problem)
- Total latency ≈ max(individual latencies), not their sum
- All agents must finish before the synthesizer can run
- Synthesizer design is critical — a weak synthesizer wastes the quality of the specialists

**Best for:**
- Research tasks that benefit from multiple independent angles
- Analysis that should be comprehensive (skills + experience + culture fit simultaneously)
- Validation that requires independent checks (security + performance + accessibility)

**Avoid when:**
- Agents have data dependencies (B needs A's output) → use Pipeline instead
- Results conflict and the synthesizer can't resolve disagreements → add a Debate step
- The overhead of running all agents outweighs the benefit when only 1-2 would be needed

---

## Type 4 — Competing Perspectives (Debate)

```
               ┌──▶ [Agent A: Perspective 1] ──┐
Input ─────────┤                               ├──▶ [Synthesis Agent] ──▶ Output
               └──▶ [Agent B: Perspective 2] ──┘
```

**Description:** Two or more agents work on the same problem from explicitly opposing or complementary perspectives. A synthesis agent combines their outputs into a balanced, explicitly trade-off-aware conclusion.

**Properties:**
- Surfaces blind spots that a single-perspective agent would miss
- Forces explicit representation of opposing views
- Higher cost: multiple agents + synthesis
- Higher quality for high-stakes decisions

**Best for:**
- High-stakes decisions (hire/no-hire, approve/reject proposal)
- Risk assessment (a pessimist and an optimist on the same problem)
- Creative tasks that benefit from contrast (two different tone/style drafts)
- Any output where bias from a single perspective would be harmful

**Perspective design:** The key is to give each agent a genuinely different mandate, not just a cosmetically different prompt. "Be positive" vs. "be negative" is weak. "Find every reason this candidate is an exceptional hire" vs. "find every reason this candidate is a risk" is strong.

---

## Type 5 — Hierarchical

```
[Orchestrator]
├── [Sub-orchestrator A]
│   ├── [Specialist A1]
│   └── [Specialist A2]
└── [Sub-orchestrator B]
    ├── [Specialist B1]
    └── [Specialist B2]
```

**Description:** Multiple levels of coordination. A top-level orchestrator delegates to sub-orchestrators, each of which manages its own specialist team. The hierarchy reflects the sub-domain structure of the problem.

**Properties:**
- Scales to large agent teams without creating an unmanageable flat team
- Each sub-domain has its own coordination layer
- Significantly more complex than flat architectures
- Failure and tracing are harder across levels

**Best for:**
- Very large systems with clearly distinct sub-domains (enterprise systems)
- When a flat Supervisor pattern has too many direct reports (>6 specialists)
- Systems where different sub-domains need different coordination strategies

**Avoid when:**
- The problem doesn't genuinely have nested sub-domains (hierarchy is artificial)
- The team is small (≤5 agents) → unnecessary overhead
- You haven't validated the flat Supervisor pattern first

**Rule:** Default to a flat Supervisor. Add hierarchy only when you have concrete evidence that the flat structure is insufficient.

---

## Type 6 — Collaborative / Blackboard

```
               ┌──▶ [Agent A] ──writes──▶ ┌───────────┐
Input ─────────┤                          │ BLACKBOARD │ ──▶ [Synthesizer] ──▶ Output
               └──▶ [Agent B] ──writes──▶ │  (shared  │
               └──▶ [Agent C] ──reads──▶  │   store)  │
                                           └───────────┘
```

**Description:** Agents share a common data store (blackboard). They read from it, add their contributions, and react to what others have written. Coordination is implicit — agents respond to state changes rather than direct messages.

**Properties:**
- Maximum decoupling between agents
- Natural for iterative refinement (agents add to a shared artifact)
- Causality is hard to trace without explicit logging
- Risk of concurrent write conflicts (see `anti-patterns.md`)

**Best for:**
- Collaborative document generation (each agent contributes to sections)
- Iterative analysis (agents refine a shared assessment over multiple passes)
- Open-ended exploration where the set of contributing agents isn't fixed upfront

---

## Type 7 — Hybrid

Most production multi-agent systems use a combination:

```
Example: Supervisor + Pipeline + Debate hybrid

User ──▶ [Orchestrator]
              ├── routes to ──▶ [Pipeline: Extract → Analyze → Format]  (for structured tasks)
              ├── routes to ──▶ [Debate: Pro + Con → Synthesis]          (for decisions)
              └── routes to ──▶ [Parallel: Check1 + Check2 + Check3]    (for validation)
```

**Naming the hybrid explicitly:** When designing a hybrid, name each segment's pattern. "We use a Supervisor at the top level, with a Pipeline for document processing and Parallel + Synthesizer for validation" is a clear architectural statement. "We have some agents that do stuff" is not.
