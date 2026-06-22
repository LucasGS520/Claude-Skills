# Anti-Patterns — Problems to Actively Avoid in Multi-Agent Architectures

These are the most common structural failures in multi-agent systems. Each one has a recognizable symptom, a root cause, and a concrete fix. Review this list before declaring any design final.

---

## 1. Agent Soup

**Description:** Too many agents with overlapping or poorly differentiated responsibilities. Nobody can explain what each agent does uniquely.

**Symptoms:**
- Team has 8+ agents but the task could be described in 3 sentences
- Multiple agents can answer the same type of request
- The "orchestrator" has to try different agents to see which one handles a given input
- Documentation says things like "Agent A handles resumes and also helps with messages sometimes"

**Root cause:** Agents were created reactively ("we need an agent for X") without first mapping the full responsibility space and checking for overlap.

**Fix:**
1. List every agent and its one-sentence sole responsibility
2. For every pair of agents, ask: "can both of these handle the same input type?" If yes, merge or redefine
3. Apply the single-sentence test: if you can't describe the agent without "and", split or redefine
4. Target: every agent has a unique, non-overlapping responsibility

---

## 2. God Orchestrator

**Description:** The orchestrator accumulates domain responsibilities over time, doing both coordination and execution.

**Symptoms:**
- Orchestrator system prompt is 1500+ words covering multiple domains
- Orchestrator has 8+ tools, including domain-specific ones
- When asked "analyze this resume", the orchestrator does it itself instead of delegating
- The orchestrator produces primary output, not just synthesized output

**Root cause:** It's tempting to "just do it in the orchestrator" when a specialist isn't working well. This creates a boundary violation that compounds.

**Fix:**
- Hard rule: the orchestrator may only route, delegate, and synthesize
- The orchestrator's toolset: routing tools only (no domain data retrieval, no external API calls)
- Extract any domain work from the orchestrator into a dedicated specialist
- The orchestrator's system prompt should read like a project manager's playbook, not a specialist's playbook

---

## 3. Circular Delegation

**Description:** Agent A delegates to Agent B, which delegates to Agent C, which delegates back to Agent A. The system deadlocks or loops.

**Symptoms:**
- Stack overflow or timeout in the orchestrator
- Logs show A → B → C → A → B → C... repeating
- One request never completes

**Root cause:** The delegation graph has a cycle. Often created when two agents each believe the other is responsible for a shared task.

**Fix:**
- Map the delegation graph as a directed acyclic graph (DAG) before implementation
- Hard rule: delegation flows strictly downward (orchestrator → specialists) or sideways (specialist → tool agents) — never upward or in cycles
- Code review: grep for any agent calling the orchestrator — that's a cycle

---

## 4. Responsibility Overlap

**Description:** Two agents produce the same type of output or answer the same type of question. The orchestrator has to arbitrarily choose between them, or worse, calls both.

**Symptoms:**
- Two agents can both score a resume
- The synthesizer receives duplicate or contradictory outputs on the same question
- Adding a new agent for a slightly different use case but the old agent "could handle it too"

**Root cause:** Boundaries were not explicitly defined before implementation. Agents drifted into each other's domains.

**Fix:**
- Complete the responsibility matrix before creating any agent (name, sole responsibility, cannot do)
- Review the matrix at every team change: does the new agent's responsibility overlap with any existing agent?
- If two agents overlap, either: merge them, redefine one's boundary to exclude the overlap, or create a Router that explicitly decides which to call

---

## 5. Chatty Agents

**Description:** Agents communicate too frequently, in too small increments, producing a high number of inter-agent calls for a simple task.

**Symptoms:**
- 20+ agent calls to complete what should be a 3-step process
- Log shows: A calls B, B returns one sentence, A calls B again, B returns one more sentence...
- Latency is dominated by inter-agent communication overhead, not by reasoning

**Root cause:** Agents were designed with too fine-grained interfaces (micro-agent problem). Each call does too little.

**Fix:**
- Design coarse-grained agent interfaces: each call should accomplish a meaningful unit of work
- Batch related decisions into one call ("analyze the resume and generate 5 interview questions" is one agent call, not two)
- If an agent makes many calls to another agent in one task, consider merging them

---

## 6. Missing Failure Contracts

**Description:** Agents don't declare what they return when something goes wrong. Callers handle errors inconsistently or not at all.

**Symptoms:**
- Agent returns `None`, empty dict, or raises an exception on failure
- The orchestrator crashes with `AttributeError: 'NoneType' object has no attribute 'score'`
- Different callers check for failure differently: one checks for None, another catches exceptions, another looks for an empty list

**Root cause:** Failure behavior was not designed — it was discovered in production.

**Fix:**
- Every agent's output schema must include an explicit failure type:
```python
class AnalysisResult(BaseModel):
    success: bool
    error: AnalysisError | None = None  # populated when success=False
    score: float | None = None          # populated when success=True
    ...

class AnalysisError(BaseModel):
    code: str     # "RESUME_TOO_SHORT", "PARSE_FAILED", "MODEL_ERROR"
    message: str
    recoverable: bool  # can the orchestrator retry?
```
- Never let an agent raise an unhandled exception — always catch and return a structured error
- The orchestrator must handle both the success and failure cases explicitly

---

## 7. Context Window Abuse

**Description:** Agents receive far more context than they need, causing slow responses, high token costs, and degraded quality (models attend less to relevant content when buried in noise).

**Symptoms:**
- Every agent receives the full conversation history on every call
- Passing a 50-page document to an agent that only needs one section
- Response quality degrades as context grows
- Token costs are dominated by input, not output

**Root cause:** "More context = better" intuition. Actually, the right context at the right granularity is better.

**Fix:**
- Extract and pass only the relevant fields to each agent (not the full document)
- Limit injected history to the N most relevant turns, not all history
- Use retrieval (vector search) to pull only the relevant sections of large documents
- Design each agent's input schema to be minimal: only what the agent genuinely needs

---

## 8. Hidden Agent State

**Description:** Agents maintain internal state that is not visible to the orchestrator or observable through logging. Behavior changes unexpectedly between calls.

**Symptoms:**
- "The same input produced different output" without any visible explanation
- Bugs that are impossible to reproduce because they depend on invisible previous calls
- Agent behavior drifts over long sessions in ways no one can explain

**Root cause:** State lives inside the agent (in-memory variables, side-effects of previous calls) rather than in declared, owned, observable stores.

**Fix:**
- All persistent state must live in explicitly declared stores (database, session history, workflow state)
- Agents are ideally stateless between calls: all context they need is injected, all output is returned
- If an agent must maintain state, that state must be logged on every mutation

---

## 9. Premature Parallelism

**Description:** Agents run in parallel when they have data dependencies — one agent needs the other's output but both start at the same time.

**Symptoms:**
- Agent B receives `None` or incomplete data because Agent A hasn't finished yet
- Race conditions: sometimes B gets A's result, sometimes it doesn't
- Intermittent failures that are hard to reproduce

**Root cause:** Data flow was not mapped before choosing the parallelism model. Parallelism was assumed to be free.

**Fix:**
- Map data dependencies explicitly before deciding what can run in parallel
- Parallel only when: Agent A and Agent B have no data dependency on each other
- Sequential when: B needs A's output, or A and B write to the same state

---

## 10. No Observability

**Description:** The system produces outputs but there is no way to understand why — what agents ran, in what order, what each received and returned, where time was spent.

**Symptoms:**
- "The system gave a wrong answer" — no way to trace which agent produced the bad output
- "The system is slow" — no way to know which step is the bottleneck
- Debugging requires adding print statements and re-running

**Root cause:** Observability was not designed as a first-class component.

**Fix:**
- Log at every agent boundary: agent name, input hash (not content, for privacy), output key fields, duration, success/failure
- Assign a correlation ID to every request that propagates through all agent calls
- Use structured logging (JSON) from the start — plain text logs don't scale
- Instrument token usage per agent (costs need to be attributable)

---

## Anti-Pattern Review Checklist

Before finalizing any multi-agent design, verify:

- [ ] Every agent has a unique, non-overlapping sole responsibility
- [ ] The orchestrator has zero domain tools and produces no primary output
- [ ] The delegation graph has no cycles (draw it)
- [ ] Every agent's output schema includes an explicit failure type
- [ ] Every agent's input is scoped to exactly what it needs (not "all context")
- [ ] All agent state is declared, owned, and observable
- [ ] Data dependencies are mapped; parallel agents have been verified as independent
- [ ] Observability: every agent boundary emits a structured log event
