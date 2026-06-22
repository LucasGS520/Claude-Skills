# Memory in Multi-Agent Systems

Memory is one of the most underspecified aspects of multi-agent architecture. The default "just pass context around" approach breaks at scale, across sessions, and when multiple agents need access to overlapping information. Design memory explicitly.

---

## Two Fundamental Distinctions

Before choosing anything else, answer two questions:

**1. How long does this information need to live?**
- Duration of one agent call → in-context (working memory)
- Duration of one task run → workflow state
- Duration of one session → session history
- Permanently, across all sessions → long-term memory

**2. Who needs access?**
- One agent only → per-agent memory
- Multiple agents in the same run → shared workflow state or blackboard
- Any agent at any time → persistent shared store

---

## Memory Type Taxonomy

### 1. Working Memory (In-Context)

**What it is:** The agent's active context window — everything in the current prompt.

**Scope:** One agent invocation. Disappears when the call ends.

**Capacity:** Limited by the model's context window (typically 32K–200K tokens). The larger the working memory, the slower and more expensive the call.

**Characteristics:**
- Fastest access (no I/O)
- No persistence — must be re-injected every call if needed again
- Finite: putting everything in context doesn't scale

**Design rule:** Working memory should contain only what the agent genuinely needs for this specific call. Not the entire conversation history. Not all documents. Only the relevant slice.

---

### 2. Workflow State

**What it is:** The intermediate results and progress tracking for one task execution.

**Scope:** One task run (from trigger to final output). Persists across agent steps within the same run.

**What belongs here:**
- Current pipeline step
- Outputs from completed steps (as structured data, not raw text)
- Retry count for the current step
- Flags for which optional steps were skipped
- Correlation ID that links all steps of this run

**Design rule:** Workflow state is owned by the orchestration layer. Specialist agents do not write to workflow state directly — they produce structured output, and the orchestrator records it.

**Implementation:** Can be in-memory (for fast, short runs) or persisted to a database (for long-running or resumable workflows).

---

### 3. Session History

**What it is:** The record of past interactions within a single session — the conversation turns, the decisions made, what the user asked.

**Scope:** One session (from session start to session end, typically one user interaction thread).

**Purpose:** Enables an agent to answer "what did we discuss earlier?" and maintain conversational continuity.

**Characteristics:**
- Must be stored externally (database) if the session spans multiple agent calls
- Growing over time within a session: inject only the N most recent turns, not all of them
- Multi-agent concern: decide early whether session history is per-agent or shared

**Key decision:** In a multi-agent system, does session history belong to one agent (the orchestrator) or is it shared across all agents? In most designs, the orchestrator holds the session history and passes only the relevant context to each specialist.

---

### 4. Long-Term Memory

**What it is:** Facts and context that persist indefinitely across sessions, available for future use.

**Subtypes:**

| Subtype | Stores | Examples |
|---|---|---|
| **Episodic** | What happened in past interactions | "Last week, HR mentioned they prefer candidates with field experience over academic credentials" |
| **Semantic** | Facts about entities and the domain | "Candidate João Silva has 5 years of Python experience and prefers remote work" |
| **Procedural** | How to do things; learned preferences | "For this team, always highlight teamwork skills in the manager briefing" |

**Storage options:**

| Storage | Best for | Trade-offs |
|---|---|---|
| Relational DB | Structured facts, filterable by field | Fast structured queries; less flexible for unstructured content |
| Vector store | Semantic search over unstructured content | Semantic recall; less precise for exact field lookups |
| Key-value store | Fast lookup by known ID | No search; requires knowing the key |
| Knowledge graph | Relationships between entities | Rich relationship queries; complex to maintain |

**Design rule for long-term memory:** Decide upfront what is worth remembering and what is not. Storing everything degrades retrieval quality (too much noise) and increases cost. Define explicit memory-worthy criteria: "store facts that would change how the agent responds to a similar future request."

---

## Memory Scope — Individual vs. Shared

### Per-Agent Memory

Each agent maintains its own memory, invisible to other agents. The agent is the sole reader and writer.

**Use when:** The memory is specific to that agent's domain and would be noise for other agents. Example: the AgenteAnaliseCurriculo accumulates patterns about what scoring criteria the team has validated over time — this is not useful to the AgenteMensagemPersonalizada.

### Shared Memory

Multiple agents read from the same memory store. Write access may be restricted to one owner.

**Use when:** Multiple agents need the same facts. Example: all agents need access to the candidate's profile — name, experience, job preferences. Maintaining copies per-agent creates inconsistency.

**Single writer principle:** For every shared memory field, designate one agent as the writer. All others are read-only. Two agents writing the same field concurrently without coordination is a race condition.

---

## Memory Consistency in Multi-Agent Systems

The primary risk with shared memory in multi-agent systems is **inconsistency** — two agents reading different versions of the same fact, or two agents writing conflicting updates.

**Three-tier protection:**

1. **Single writer per field** — the simplest and most effective rule. If only one agent writes a field, there are no concurrent write conflicts.

2. **Transactions** — when a sequence of reads and writes must be atomic. If Agent A reads a value and then writes based on it, no other agent should write between the read and the write.

3. **Eventual consistency awareness** — in async / event-driven systems, agents may read memory that hasn't been updated yet by another agent that just finished. Design agents to handle this: check timestamps, handle "not available yet" gracefully.

---

## Memory Specification Template

For each agent, specify:

```yaml
agent: AgenteAnaliseCurriculo
working_memory:
  - resume_text (injected per call)
  - job_description (injected per call)
  - past_5_analyses_from_session (from session history)

session_history:
  owner: Orchestrator
  shared: false  # this agent gets a summary, not full history

long_term_memory:
  reads:
    - candidate_profile (from shared semantic store)
    - team_scoring_preferences (from per-agent episodic store)
  writes:
    - analysis_result (to workflow state, owned by this agent)
  owns:
    - team_scoring_preferences (per-agent episodic)
```

---

## Common Memory Anti-Patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| **Context stuffing** | Every call injects the entire conversation history | Inject only the relevant N recent turns or a structured summary |
| **No long-term memory** | Agents "forget" user preferences every session | Add a Memory Agent or enable agentic memory in the framework |
| **Shared mutable state without ownership** | Two agents write the same field; results are non-deterministic | Assign one owner per field; all others read-only |
| **Memory as coordination** | Agents use a shared DB to coordinate instead of explicit messages | Make coordination explicit; shared memory is for persistence, not signaling |
| **Storing everything** | Long-term memory grows unbounded; retrieval quality degrades | Define explicit criteria for what is worth storing |
