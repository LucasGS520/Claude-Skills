# Communication Patterns — How Agents Exchange Information

Communication between agents is one of the most consequential design decisions in a multi-agent system. The pattern chosen affects latency, coupling, debuggability, and resilience. Choose consciously.

---

## The Four Communication Dimensions

Before choosing a pattern, answer these four questions:

| Dimension | Options | Default |
|---|---|---|
| **Direction** | Direct (A → B) or Broadcast (A → all) | Direct |
| **Timing** | Synchronous (caller waits) or Asynchronous (fire and read later) | Synchronous |
| **Format** | Structured (typed schema) or Unstructured (natural language) | **Always structured between agents** |
| **Coupling** | Tight (A knows B exists) or Loose (A writes to shared space) | Depends on pattern |

**Non-negotiable rule: agents must always communicate with structured schemas between themselves.** Natural language between agents is unverifiable, unparseable programmatically, and a primary source of emergent bugs. Natural language is for the final user output only.

---

## Pattern 1 — Direct Message Passing

**Description:** Agent A sends a structured message directly to Agent B and waits for a structured response (synchronous) or posts to a queue and reads the response later (asynchronous).

```
Agent A ──[structured message]──▶ Agent B
Agent A ◀──[structured response]── Agent B
```

**Synchronous variant:**
```python
# A calls B and blocks until B responds
result = agent_b.run(
    AnalysisRequest(
        resume_text=resume.text,
        job_description=job.description,
        required_skills=job.required_skills,
    )
)
# A continues with result.content
```

**Asynchronous variant:**
```python
# A posts to queue and continues; reads result when needed
await queue.put(AnalysisRequest(...))
# ... other work ...
result = await queue.get()
```

**Characteristics:**
- Tight coupling: A knows B's interface explicitly
- Easy to trace: one call, one response
- Simple debugging: if B is broken, A fails in an obvious way
- Bottleneck: sequential by default; parallelism requires explicit design

**Use when:** The caller needs the result before it can proceed (data dependency). The architecture has clear sequential handoffs.

---

## Pattern 2 — Shared Memory (Blackboard)

**Description:** Agents do not communicate directly. They read from and write to a common data store (the "blackboard"). Coordination emerges from state changes, not direct calls.

```
Agent A ──[write result]──▶ ┌─────────────┐ ◀──[read result]── Agent B
                            │  BLACKBOARD  │
Agent C ──[write result]──▶ │  (shared    │ ◀──[read trigger]── Agent D
                            │   store)    │
                            └─────────────┘
```

**Characteristics:**
- Loose coupling: agents don't know who else is reading or writing
- Scales well: adding a new agent doesn't change existing agents
- Harder to trace: causality is implicit (who triggered whom?)
- Risk: two agents writing the same field simultaneously (see `anti-patterns.md`)

**Use when:** Agents contribute independent partial results to a shared view. The system needs to scale to many agents without increasing coupling. Debugging causality is less important than decoupling.

**Implementation notes:**
- Assign each field in the blackboard to exactly one owner (single writer principle)
- Use transactions or optimistic locking if concurrent writes are unavoidable
- Log every write with timestamp and agent identity for traceability

---

## Pattern 3 — Event-Driven (Pub/Sub)

**Description:** Agents publish events when they complete work. Other agents subscribe to the events they care about and react when relevant events arrive.

```
Agent A ──[publishes: ResumeAnalyzed]──▶ ┌──────────┐
                                          │  Event   │──▶ Agent B (subscribed to ResumeAnalyzed)
                                          │   Bus    │──▶ Agent C (subscribed to ResumeAnalyzed)
                                          └──────────┘
```

**Characteristics:**
- Very loose coupling: publishers don't know who is listening
- Naturally asynchronous: agents react when ready
- Hard to trace the full execution path without distributed tracing tooling
- Fan-out: one event can trigger multiple downstream agents

**Use when:** Multiple agents react to the same event (fan-out). The system is built around state transitions (e.g., candidate status changes). Temporal decoupling is needed (producer and consumer don't need to be active at the same time).

**Event schema discipline:** Define every event with a strict schema — event type, timestamp, producing agent, payload schema, correlation ID. Never publish untyped events.

```python
class ResumeAnalyzed(BaseModel):
    event_type: Literal["ResumeAnalyzed"] = "ResumeAnalyzed"
    correlation_id: str           # links this event to the original request
    candidate_id: str
    job_id: str
    score: float
    strengths: list[str]
    attention_points: list[str]
    produced_by: str              # agent name
    timestamp: datetime
```

---

## Pattern 4 — Structured Handoff (Pipeline)

**Description:** A linear chain where each agent's structured output is the next agent's structured input. A variant of direct message-passing but with a fixed, pre-determined sequence.

```
Input ──▶ [Agent A] ──▶ HandoffA ──▶ [Agent B] ──▶ HandoffB ──▶ [Agent C] ──▶ Output
```

**Characteristics:**
- Highly auditable: data transformation is visible at every step
- Each step is independently testable (give it the handoff schema, check the output)
- Sequential latency: total time = sum of all steps
- Brittle: one step failing breaks the whole pipeline unless handled explicitly

**Handoff schema design:** Define a separate schema for each handoff. Do not pass the raw input of Step 1 to Step 3 — each step should consume only what it produced plus what it needs.

```python
# Step 1 output / Step 2 input
class ResumeExtractionResult(BaseModel):
    candidate_id: str
    raw_text: str
    detected_skills: list[str]
    detected_experience_years: int | None

# Step 2 output / Step 3 input
class ResumeAnalysisResult(BaseModel):
    candidate_id: str
    adherence_score: float          # only this step adds the score
    strengths: list[str]
    gaps: list[str]
    suggested_questions: list[str]
    # raw_text is NOT passed forward — Step 3 doesn't need it
```

---

## Synchronous vs. Asynchronous — The Decision

| | Synchronous | Asynchronous |
|---|---|---|
| **When** | Caller needs result before continuing | Caller can do other work while waiting |
| **Debugging** | Easier — stack trace shows the chain | Harder — must correlate across time |
| **Latency** | Sequential — steps add up | Can parallelize independent steps |
| **Failure handling** | Exception propagates immediately | Must handle delayed/missing results |
| **Default choice** | Yes — unless you have a specific reason not to | Only when parallelism or decoupling is a concrete requirement |

**Practical rule:** Start with synchronous. Move to asynchronous only when you have a measured latency problem or a concrete decoupling requirement. Async complexity is a real cost.

---

## Choosing a Pattern

```
Data dependency between A and B (B needs A's result)?
  → Direct message-passing (synchronous)

Independent agents contributing to a shared view?
  → Shared memory / Blackboard

One event should trigger multiple independent agents?
  → Event-driven (pub/sub)

Fixed sequence of transformations with clear handoffs?
  → Structured handoff (pipeline)

Multiple patterns needed in different parts of the system?
  → Hybrid (name each segment's pattern explicitly)
```
