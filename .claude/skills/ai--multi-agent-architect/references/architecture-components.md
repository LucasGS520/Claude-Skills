# Architecture Components — The Building Blocks of a Multi-Agent Layer

A multi-agent layer is not just a collection of agents. It is a structured system with seven distinct components. Understanding each component and its responsibilities is the prerequisite for a coherent design.

```
┌───────────────────────────────────────────────────────────────────┐
│                     MULTI-AGENT LAYER                            │
│                                                                   │
│  ┌──────────────────┐      ┌─────────────────────────────────┐   │
│  │  Human Interface │      │      Orchestration Layer        │   │
│  │  (approval,      │◀────▶│  (routing, delegation,         │   │
│  │   feedback,      │      │   synthesis, workflow state)    │   │
│  │   override)      │      └──────────┬──────────────────────┘   │
│  └──────────────────┘                 │ delegates                 │
│                                       ▼                           │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                      AGENTS                               │   │
│  │   ┌────────────┐  ┌────────────┐  ┌────────────┐         │   │
│  │   │ Specialist │  │ Specialist │  │  Reviewer  │  ...    │   │
│  │   └─────┬──────┘  └─────┬──────┘  └─────┬──────┘         │   │
│  └─────────┼───────────────┼───────────────┼────────────────┘   │
│            │               │               │                      │
│  ┌─────────▼───────────────▼───────────────▼────────────────┐   │
│  │              Communication Infrastructure                 │   │
│  └─────────────────────────┬─────────────────────────────────┘   │
│            ┌───────────────┼───────────────┐                      │
│            ▼               ▼               ▼                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Tool Layer  │  │Memory Stores │  │Observability │           │
│  │ (APIs, DBs,  │  │(DB, vectors, │  │(logs, traces,│           │
│  │  functions)  │  │ key-value)   │  │  metrics)    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└───────────────────────────────────────────────────────────────────┘
```

---

## 1. Agents (The Basic Units)

The agents are the reasoning units of the system. Each agent encapsulates:

- **Model** — the LLM powering the agent's reasoning (can differ per agent)
- **System prompt (instructions)** — defines the agent's role, behavior, and output format
- **Tools** — the specific capabilities the agent can invoke (only the tools it needs)
- **Memory** — the agent's access to past context and persistent knowledge

**Design rule:** An agent should be specifiable on a single index card — name, one-sentence role, inputs, outputs, tools. If it doesn't fit on an index card, it's too broad.

---

## 2. Orchestration Layer

The orchestration layer is the "nervous system" of the multi-agent architecture. It is responsible for:

- **Decomposition** — breaking the incoming task into subtasks
- **Delegation** — routing each subtask to the right agent
- **Synchronization** — managing dependencies between agents (who must finish before who can start)
- **Synthesis** — combining agent outputs into a coherent final result
- **Workflow state** — tracking where the system is in the overall task

**Critical constraint:** The orchestration layer must not execute domain work. It is a coordinator, not a specialist. An orchestrator that starts doing analysis or writing is an orchestrator with boundary violations.

**Implementation options:**
- A dedicated Orchestrator agent (LLM-based, decides dynamically)
- A deterministic workflow engine (code-based, follows a fixed graph)
- Hybrid: a workflow engine for the happy path + an LLM orchestrator for exceptions

---

## 3. Communication Infrastructure

The communication infrastructure defines how agents exchange information. It is a cross-cutting concern that affects every agent in the system.

Key decisions at this layer:
- **Pattern:** message-passing, shared memory, event-driven, or hybrid (see `communication-patterns.md`)
- **Format:** structured (JSON/Pydantic schemas) vs. unstructured (natural language)
- **Timing:** synchronous (caller waits) vs. asynchronous (caller continues, reads result later)

**Design rule:** Agents should not communicate through natural language blobs between themselves. Define structured schemas for inter-agent messages. Natural language is for the final output to users.

---

## 4. Tool Layer

The tool layer is the set of external capabilities that agents can invoke — APIs, databases, file systems, code executors, search engines, external services.

**Principle of least privilege:** Each agent should have access only to the tools it genuinely needs for its responsibility. An analysis agent does not need a calendar API. A message-drafting agent does not need database write access.

**Tool categories:**

| Category | Examples | Who should hold it |
|---|---|---|
| Data retrieval | Database queries, vector search, web search | Specialist agents that need the data |
| Action execution | Send email, write file, call API | Tool agents (dedicated stateless executors) |
| Data transformation | Parse PDF, OCR image, extract entities | Specialist agents or dedicated parser agents |
| Computation | Code execution, calculations | Dedicated tool agents |

---

## 5. Memory Stores

Memory stores provide persistence beyond the context window. There are three distinct memory concerns in a multi-agent system:

| Memory type | Stores | Scope | Persists across |
|---|---|---|---|
| **Workflow state** | Current step, intermediate results, retry counts | One execution | Steps within one run |
| **Session history** | Conversation turns, past decisions | One session | Runs within one session |
| **Long-term memory** | User preferences, entity facts, learned knowledge | Persistent | All sessions |

The full taxonomy and implementation guidance is in `memory-systems.md`.

---

## 6. Human Interface

The human interface is the set of touchpoints where humans participate in the multi-agent process. In systems where AI acts on behalf of humans, this component is not optional — it is a design requirement.

**Human interface functions:**

| Function | When needed | Example |
|---|---|---|
| **Approval gate** | Before any irreversible or externally-visible action | HR approves the outreach message before it is sent |
| **Review interface** | When AI output quality must be validated before use | HR reviews the AI's resume analysis before forwarding to the manager |
| **Override** | When a human must be able to halt or redirect the system | HR changes the candidate status, overriding the AI's suggested next step |
| **Feedback loop** | When the system should learn from human corrections | HR marks an analysis as incorrect; the system records the feedback |

**Design rule:** Every irreversible action in the system must have a human approval gate. The agent recommends; the human decides.

---

## 7. Observability Layer

The observability layer makes the system's behavior visible, traceable, and debuggable.

**Three pillars:**

| Pillar | What it captures | Why it matters |
|---|---|---|
| **Logs** | Structured events: agent called, input received, output produced, tool invoked | Audit trail; debugging |
| **Traces** | End-to-end request trace across all agent calls | Understanding which agents ran, in what order, and how long |
| **Metrics** | Latency, error rate, token usage, agent call count | Performance monitoring; cost control |

**Minimum viable observability:** For every agent invocation, log: timestamp, agent name, input hash (not content, for privacy), output schema key fields, duration, success/failure.

**Design rule:** If you can't answer "why did the system produce this output?" by reading the logs, the observability layer is insufficient.
