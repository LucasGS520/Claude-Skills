# Fundamental Concepts — What an Agent Is, Specialization, and Coordination

## What Is an Agent?

An agent is an autonomous computational entity that operates within an environment by following a perceive → reason → act cycle:

```
┌─────────────────────────────────────────────────┐
│                     AGENT                       │
│                                                 │
│  Input ──▶ [Perceive] ──▶ [Reason] ──▶ [Act]  ──▶ Output / Action
│                              ▲                  │
│                              │                  │
│                           Memory                │
└─────────────────────────────────────────────────┘
```

**Four defining properties of an agent:**

| Property | Meaning | Implication for design |
|---|---|---|
| **Autonomy** | Operates without continuous human intervention | The agent must handle ambiguity in its inputs; its system prompt must cover edge cases |
| **Reactivity** | Perceives and responds to its environment | Input schema must match what the environment actually sends |
| **Proactivity** | Pursues goals, not just reacts to events | The agent needs a clear goal statement, not just instructions |
| **Social ability** | Interacts with other agents and humans | Communication contracts must be defined before integration |

An entity that lacks autonomy is a function call. An entity that lacks social ability is a standalone agent, not a team member.

---

## Specialization

### What It Means

Specialization is the principle that each agent should have a **narrow, deep expertise** in exactly one domain or capability. The agent does one thing and does it exceptionally well.

A specialized agent is characterized by:
- A system prompt focused on one domain (not "do X and also Y")
- A minimal, precisely scoped toolset
- An input/output contract that reflects a single responsibility
- The ability to be tested in complete isolation

### Why Specialization Matters

**Quality:** A focused system prompt produces better output than a general one. An agent told "analyze resumes and draft messages and summarize interviews" will be mediocre at all three. Three separate specialized agents will be excellent at each.

**Testability:** A specialized agent can be tested with simple mock inputs. A generalist agent requires complex multi-step scenarios to test properly.

**Replaceability:** If a specialized agent underperforms, it can be swapped for a better one without touching the rest of the system.

**Parallelism:** Independent specialized agents can run concurrently. Generalist agents block on sequential dependencies.

**Clarity of failure:** When a specialized agent fails, the failure is localized and easy to diagnose. Generalist agents fail in ambiguous ways.

### How to Design Specialization

**The one-sentence test:**
> "Can I describe what this agent does in one sentence, without using the word 'and'?"

If not, split the agent.

```
VIOLATION:  "Analyzes the resume AND drafts the outreach message"
CORRECT:    "Scores resume adherence to the job description and extracts top 3 strengths and 3 gaps"
CORRECT:    "Drafts a personalized outreach message given a candidate profile and job context"
```

**Specialization axes — choose one:**

| Axis | When to use | Example |
|---|---|---|
| By **domain** | Task spans multiple knowledge domains | HR agent, Finance agent, Legal agent |
| By **capability** | Task requires different cognitive operations | Research agent, Analysis agent, Writing agent |
| By **data source** | Agents access fundamentally different data | Database agent, Web agent, Document agent |
| By **action type** | Agents perform fundamentally different actions | Reader agent, Writer agent, Reviewer agent |

**Pitfalls:**
- **Over-specialization:** splitting what naturally belongs together creates unnecessary coordination overhead. Don't create a "read the first paragraph" agent and a "read the second paragraph" agent.
- **Premature specialization:** start with fewer, broader agents. Split only when you observe quality degradation or test failure due to mixed responsibilities.

---

## Coordination

### What It Means

Coordination is the set of mechanisms by which agents **align their actions to achieve a collective goal** that none could achieve alone. In a multi-agent system, coordination answers three questions:

1. **Who does what?** — task allocation
2. **In what order?** — sequencing and dependencies
3. **What happens when something goes wrong?** — failure handling

Without coordination, a collection of agents is not a system — it is a set of independent processes that happen to share an environment.

### Why Coordination Is Hard

**The fundamental tension:** more agents means more parallelism (good for latency and quality) but also more coordination overhead (bad for simplicity and reliability). Every inter-agent communication adds latency, potential failure points, and debugging complexity.

**Core coordination challenges:**

| Challenge | Description | Common symptom |
|---|---|---|
| **Timing** | Who acts first, and when does the next agent start? | Agent B reads stale output from Agent A |
| **Conflict** | Two agents produce contradictory results or want to take incompatible actions | Inconsistent output, race conditions on shared resources |
| **Incomplete information** | Agents don't know what other agents know | Redundant work, gaps in coverage |
| **Failure propagation** | One agent's failure cascades to others | Full pipeline stops on a partial failure |
| **Context drift** | Agents work from slightly different views of the shared context | Synthesis produces incoherent results |

### Coordination Mechanisms

**Central authority (Orchestrator)**
One agent decomposes, delegates, and synthesizes. All coordination passes through it. Simple to reason about; creates a bottleneck.

**Pipeline**
Agents form a chain: each receives the previous agent's output as its input. No central coordinator needed. Simple but sequential — the total latency is the sum of all steps.

**Negotiation**
Agents propose and respond to offers to determine who handles what. Flexible; expensive. Rarely used in LLM agent systems.

**Stigmergy (Blackboard)**
Agents communicate indirectly through a shared environment (a common data store). No direct coupling; coordination emerges from state changes. Scales well; harder to trace causality.

**Parallel + Synthesizer**
Agents run concurrently on independent subtasks. A synthesizer agent combines results. Lowest latency for independent tasks; requires a well-designed synthesizer.

**Consensus**
Agents must agree before acting. High quality for controversial decisions; high coordination cost. Use only for high-stakes outputs.

### The Coordination Cost Rule

Every added inter-agent communication step adds:
- Latency (one extra LLM call minimum)
- Potential failure (one more network/model call that can fail)
- Token cost (context passed between agents is billed)
- Debugging complexity (tracing a bug across agents is harder than within one)

**Design implication:** minimize coordination steps. Prefer coarse-grained agent interfaces. Batch work before communicating. Use the simplest coordination pattern that satisfies the requirements.
