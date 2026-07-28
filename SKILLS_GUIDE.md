# Guia Completo de Skills Globais

> Arquivo de referência pessoal — **não é uma skill**, não interfere no Claude Code.
> Local: `~/.claude/SKILLS_GUIDE.md`
> Para navegar as pastas: `ls ~/.claude/skills/`

---

## Sumário

- [Como as Skills Funcionam](#como-as-skills-funcionam)
- [ai-- → IA & Agentes](#ai----ia--agentes)
- [data-- → Análise & Dados](#data----análise--dados)
- [arch-- → Arquitetura & Infraestrutura](#arch----arquitetura--infraestrutura)
- [db-- → Banco de Dados](#db----banco-de-dados)
- [dev-- → Qualidade & Processo](#dev----qualidade--processo)
- [frontend-- → Frontend & UI](#frontend----frontend--ui)
- [learn-- → Aprendizado & Descoberta](#learn----aprendizado--descoberta)
- [tools-- → Ferramentas & Exploração](#tools----ferramentas--exploração)
- [n8n-- → Automação N8N](#n8n----automação-n8n)
- [product-- → Produto & Análise](#product----produto--análise)
- [marketing-- → Marketing & Growth](#marketing----marketing--growth)
- [composio-- → Suites de Utilidade Geral](#composio----suites-de-utilidade-geral)
- [Skills Oficiais Anthropic (Superpowers)](#skills-oficiais-anthropic-superpowers)
- [Plugins de Terceiros](#plugins-de-terceiros)
- [Ferramentas Per-Project (não instaladas globalmente)](#ferramentas-per-project-não-instaladas-globalmente)
- [Fluxos de Sinergia](#fluxos-de-sinergia)
- [Referência Rápida](#referência-rápida)

---

## Como as Skills Funcionam

**Ativação automática:** Claude Code lê o `description` de cada `SKILL.md` e ativa a skill quando detecta que a situação se encaixa. Skills do Superpowers têm gatilhos muito precisos e ativam sem você pedir.

**Ativação manual — 3 formas:**
```
1. Pedido natural:   "use a skill de debugging para investigar isso"
2. Referência direta: "aplique o fluxo de TDD aqui"
3. Slash command:    /systematic-debugging  |  /code-review
```

**Localização das skills:**
```
~/.claude/skills/          → skills globais locais (qualquer projeto)
~/.claude/plugins/cache/   → plugins de marketplace (Superpowers, frontend-design, genjutsu, gsap-skills, etc.)
<projeto>/.claude/skills/  → skills específicas de cada projeto
```

## Setup em Máquina Nova

Este repositório reproduz o setup completo (skills-pasta + plugins de marketplace) com um comando:

```bash
git clone https://github.com/LucasGS520/Claude-Skills.git
cd Claude-Skills
./install.sh
```

**O que o script faz:**
1. Copia toda `.claude/skills/*` do repo pra `~/.claude/skills/` (skills-pasta — portáteis, sem instalação real)
2. Lê `plugins.json` e roda `claude plugin marketplace add` pra cada marketplace de terceiros ainda não configurado (idempotente — pula se já existe)
3. `claude plugin marketplace update` pra garantir cache atualizado antes de instalar
4. `claude plugin install` pra cada plugin listado (oficiais Anthropic + terceiros), idempotente

**Dois mecanismos, um motivo pra cada:**

| | Skills-pasta | Plugin marketplace |
|---|---|---|
| Estrutura | só `SKILL.md` (+ `references/`, opcional) | `.claude-plugin/plugin.json` + `marketplace.json` |
| Como carrega | Claude Code varre `~/.claude/skills/*/SKILL.md` direto | sistema `/plugin` — cache em `~/.claude/plugins/cache/`, registro em `~/.claude/settings.json` |
| Portabilidade | copia pasta, funciona | precisa `marketplace add` + `install` de novo em cada máquina |
| Por que existe | zero overhead, ideal pra skill única e autocontida | pra plugins que agregam hooks/MCP/subagents/slash-commands, ou que dependem de `${CLAUDE_PLUGIN_ROOT}` pra resolver sub-skills internas (caso do `genjutsu`) — não dá pra copiar pasta manual sem quebrar |
| Update | manual (reinstala) | `claude plugin update` |

Nem toda skill de plugin pode virar pasta sem fork (genjutsu, e os oficiais Anthropic dependem do mecanismo). Por isso o repo padroniza o **processo** (`install.sh` + `plugins.json`), não o mecanismo — reproduz os dois tipos com um comando só, independente de qual é qual.

**Ao instalar uma skill nova:** se for skills-pasta, `cp` pra `.claude/skills/<categoria>--<nome>/` no repo (padrão já seguido). Se for plugin de marketplace, adiciona a entrada em `plugins.json` (marketplace + id do plugin) — não precisa editar `install.sh`.

**Status GitHub:** o repositório público [`LucasGS520/Claude-Skills`](https://github.com/LucasGS520/Claude-Skills) rastreado por `origin/main` contém 47 skills com `SKILL.md`. Estas 8 skills existem localmente, mas ainda não estão em `origin/main`: `dev--security-auditor`, `tools--cavecrew`, `tools--caveman`, `tools--caveman-commit`, `tools--caveman-compress`, `tools--caveman-help`, `tools--caveman-review`, `tools--caveman-stats`.

---

## ai-- → IA & Agentes

### `ai--agno` Fonte idiomática oficial
**O que é:** Skill oficial do framework Agno — referência canônica para padrões idiomáticos, APIs e boas práticas ao construir agentes, times, workflows e integrações MCP com o Agno SDK.

**Fonte:** [`agno-agi/agno-skills`](https://github.com/agno-agi/agno-skills/tree/main/plugins/agno/skills/agno) — instalada globalmente em `~/.claude/skills/ai--agno/SKILL.md`

**Responsabilidades:**
- Padrões corretos de Agent (model, tools, memory, structured output, session persistence)
- Multi-agent Teams — modos `route`, `broadcast`, `tasks` com coordenação por líder
- Workflows sequenciais e paralelos (Step, Parallel, Condition, Loop, Router)
- Integração com MCP servers — stdio, SSE e Streamable HTTP — com lifecycle correto
- AgentOS: deploy de agentes em produção
- LearningMachine: perfis de usuário, memória de entidades e aprendizado persistente
- Regras críticas do framework (nunca criar agentes em loops, sempre fechar conexões MCP, etc.)

**Quando usar:**
- Sempre que escrever qualquer código Agno — como regra canônica de como o framework deve ser usado
- Implementar agentes em projetos especificios (`ResearchAgent`, `Business Agent`, etc.)
- Decidir entre Agent vs Team vs Workflow para um caso de uso
- Depurar comportamento inesperado de um agente (`debug_mode=True`)
- Integrar um MCP server ao projeto em questão.

**Regras críticas a seguir sempre:**
- **Nunca** criar agentes dentro de loops — declare fora e reutilize
- **Sempre** fechar conexões MCP com `async with` ou `try/finally`
- Usar `output_schema` (Pydantic) para saídas estruturadas — nunca parsear texto livre
- Métodos `async` têm prefixo `a` (`aprint_response`, `arun`, etc.)

**Sinergia com:** `ai--prompt-engineer` (conteúdo dos system prompts) + `ai--agent-development` (estrutura do agente no Claude Code) + `dev--python-pro` (código Python idiomático)

---

### `ai--agent-development`
**O que é:** Toolkit completo para criar agentes no Claude Code — estrutura, frontmatter, system prompts, configuração de tools e definição de triggers de ativação.

**Responsabilidades:**
- Definir a estrutura de um agente (frontmatter, description, tools permitidas)
- Escrever system prompts eficazes para agentes especializados
- Configurar quando e como o agente é ativado
- Validar a qualidade do agente criado

**Quando usar:**
- Criar agentes (`ResearchAgent`, `Business Agent`, etc.)
- Estruturar qualquer agente ou subagente no Claude Code
- Revisar e melhorar agentes existentes

---

### `ai--multi-agent-architect`
**O que é:** Arquiteto de sistemas multi-agente — planeja, define e especifica arquiteturas de camadas de agentes antes de qualquer código ser escrito.

**Responsabilidades:**
- Justificar quando multi-agente é realmente necessário vs. agente único com mais ferramentas
- Definir fronteiras e responsabilidade única de cada agente (input/output contracts)
- Escolher o tipo de arquitetura (Pipeline, Supervisor, Paralelo, Hierárquico, Debate)
- Projetar o modelo de comunicação entre agentes (message-passing, shared memory, event-driven)
- Especificar sistemas de memória e propriedade do estado compartilhado
- Mapear anti-patterns estruturais a evitar (ciclos, sobreposição de responsabilidade, orchestrator executando trabalho de domínio)
- Produzir especificação arquitetural completa antes da implementação

**Diferença de `ai--agno`:** `ai--multi-agent-architect` decide **como estruturar** o sistema (topologia, coordenação, fronteiras). `ai--agno` sabe **como implementar** com o framework Agno. Use `multi-agent-architect` primeiro para o design, depois `ai--agno` para o código.

**Sinergia:** `ai--multi-agent-architect` → `ai--agno` → `ai--agent-development` + `ai--prompt-engineer`

---

### `ai--rag-architect`
**O que é:** Especialista em sistemas RAG (Retrieval-Augmented Generation) de nível produção.

**Responsabilidades:**
- Estratégias de chunking de documentos
- Geração e armazenamento de embeddings
- Configuração de vector stores (pgvector, Pinecone, Weaviate)
- Pipelines de busca híbrida (semântica + lexical)
- Reranking para melhorar relevância
- Avaliação de qualidade do retrieval

---

### `ai--prompt-engineer`
**O que é:** Especialista em escrever, refatorar e avaliar prompts para LLMs.

**Responsabilidades:**
- Escrever templates de prompt otimizados
- Chain-of-thought e few-shot learning
- System prompts com personas e guardrails
- Schemas JSON para structured output
- Function calling / tool use schemas
- Frameworks de avaliação de prompts (evals)
- Reduzir tokens mantendo qualidade

**Sinergia com:** `ai--agent-development` — use `ai--prompt-engineer` para o conteúdo do prompt, depois `ai--agent-development` para estruturar o agente.

---

## data-- → Análise & Dados

> Diferença de `db--`: `data--` é sobre **análise, manipulação e narrativa de dados** (pandas, relatórios, insights). `db--` é sobre **banco de dados** (SQL, schema, performance de queries).

### `data--pandas-pro`
**O que é:** Especialista em análise e manipulação de dados com pandas DataFrames.

**Responsabilidades:**
- Join de DataFrames em múltiplas chaves
- Pivot tables e reshaping de dados
- Resample e análise de séries temporais
- Handling de NaN (interpolação, forward-fill)
- GroupBy com aggregações complexas
- Conversão de tipos e validação de dados
- Otimização de performance em datasets grandes

---

### `data--storyteller`
**O que é:** Transforma dados brutos em relatórios narrativos com insights automáticos.

**Responsabilidades:**
- Processar CSV e Excel
- Auto-detectar padrões nos dados
- Gerar resumo executivo em linguagem natural
- Criar visualizações e gráficos
- Análise estatística automática
- Exportar para PDF

**Sinergia:** `data--pandas-pro` processa os dados → `data--storyteller` transforma em narrativa.

---

## arch-- → Arquitetura & Infraestrutura

### `arch--architecture-designer`
**O que é:** Especialista em design de arquitetura e estrura de sistemas de software de alto nível.

**Responsabilidades:**
- Criar diagramas de arquitetura
- Escrever Architecture Decision Records (ADRs)
- Avaliar trade-offs entre tecnologias
- Desenhar interações entre componentes
- Planejar escalabilidade e resiliência
- Definir padrões de infraestrutura

**Diferença de `arch--senior-architect`:** `architecture-designer` foca em decisões e documentação (ADRs). `arch--senior-architect` foca em diagramas visuais e análise de dependências.

---

### `arch--senior-architect`
**O que é:** Toolkit de arquiteto sênior com foco em diagramas e análise de dependências.

**Responsabilidades:**
- Gerar diagramas de arquitetura (C4, sequência, deployment)
- Análise de dependências entre componentes
- Frameworks de decisão de stack técnica
- Design patterns de sistema
- Identificar acoplamentos e pontos frágeis

---

### `arch--api-designer`
**O que é:** Especialista em design de APIs REST e GraphQL.

**Responsabilidades:**
- Modelagem de recursos e endpoints
- Criação de specs OpenAPI/Swagger
- Estratégias de versionamento
- Padrões de paginação (cursor, offset)
- Tratamento de erros padronizado
- Autenticação e autorização na API

---

### `arch--devops-engineer`
**O que é:** Especialista em containerização, CI/CD e automação de deploy.

**Responsabilidades:**
- Criar e otimizar Dockerfiles
- Configurar docker-compose
- Pipelines CI/CD (GitHub Actions)
- GitOps e automação de releases
- Runbooks de incidente e operações
- Configuração de ambientes (dev/staging/prod)

---

### `arch--browserbase-*` (16 skills)
**O que é:** Framework completo de automação de browser com Browserbase — planejamento, implementação, tracing, testes e deploy cloud.

**Fonte:** [`browserbase/skills`](https://github.com/browserbase/skills) — instaladas globalmente em `~/.claude/skills/arch--browserbase-*/SKILL.md`

| Skill | Foco |
|---|---|
| `arch--browserbase-browser` | Automate web browser (CLI, CAPTCHA, proxies, Browserbase Identity, Verified browsers) |
| `arch--browserbase-functions` | Deploy browser automation em cloud (serverless, cron, webhooks) |
| `arch--browserbase-safe-browser` | Constrained-browser agents com domain allowlist + CDP (Agent SDK) |
| `arch--browserbase-autobrowse` | Self-improving automation loop (task → trace → improve → retry) |
| `arch--browserbase-browser-trace` | DevTools CDP trace capture, per-page buckets, session debug |
| `arch--browserbase-browser-to-api` | Converte HTTP traffic (trace) em OpenAPI 3.1 spec |
| `arch--browserbase-fetch` | Lightweight HTTP (sem browser full) — HTML/JSON, status, redirects |
| `arch--browserbase-search` | Web search (sem browser) — URLs, titles, metadata |
| `arch--browserbase-ui-test` | Adversarial UI testing (git diffs, accessibility, responsive, UX heuristics) |
| `arch--browserbase-browser-use-to-stagehand` | Migrar browser-use (Python) → Stagehand (TypeScript) |
| `arch--browserbase-agent-experience` | Audit DX de SDK/docs/skill — subagents descobrem, instalam, testam (A-F grade) |
| `arch--browserbase-company-research` | Company discovery + ICP research (Plan→Research→Synthesize, scored report) |
| `arch--browserbase-competitor-analysis` | Competitor intel — 4-lane deep research (marketing, signals, benchmarks, matrix) |
| `arch--browserbase-event-prospecting` | Lead prospecting em conferências — extrai speakers, filtra ICP, deep-research |
| `arch--browserbase-cookie-sync` | Sincronizar cookies locais (Chrome) → Browserbase session (auth) |
| `arch--browserbase-webmcp-gen` | Author WebMCP init scripts (site-specific tools via Stagehand) |

**Quando usar:** qualquer tarefa de browser automation — desde interação simples (fetch, search) até automação complex (autobrowse self-improving, tracing, deploy cloud), pesquisa competitiva e testes.

**Diferença de `genjutsu:cast` (web):** `genjutsu` cobre **motion/micro-interação** dentro de uma UI já existente (CSS/JS). `browserbase-*` cobre **browser automation + data extraction** — clicar, navegar, scrape, testar, deploy.

**Sinergia com:** `arch--devops-engineer` (deploy cloud functions) + `dev--test-master` (UI testing strategy) + `product--feature-forge` (automate QA flows)

---

### `arch--monitoring-expert`
**O que é:** Especialista em observabilidade de infraestrutura — logging, métricas, tracing e performance.

**Responsabilidades:**
- Configurar Prometheus + Grafana
- Implementar logging estruturado (JSON logs)
- Criar dashboards de monitoramento (RED/USE methods)
- Definir alertas e SLOs
- Distributed tracing com OpenTelemetry
- Load testing com k6 ou Artillery
- Profiling de CPU e memória
- Capacity planning

**Sinergia com:** `arch--devops-engineer` (infra e deploy) + `dev--debugging-wizard` (investigação de problemas em produção).

---

## db-- → Banco de Dados

### `db--postgres-pro`
**O que é:** Especialista em PostgreSQL avançado com foco em features específicas do Postgres.

**Responsabilidades:**
- EXPLAIN e EXPLAIN ANALYZE detalhado
- JSONB — armazenamento e queries em JSON
- Extensões PostgreSQL (pgvector, pg_trgm, etc.)
- Configuração de VACUUM e autovacuum
- Replicação e alta disponibilidade
- Row-Level Security (RLS) para multi-tenant
- Full-text search nativo

**Diferença de `db--sql-pro`:** `db--postgres-pro` é específico para features do Postgres. `db--sql-pro` é sobre escrever SQL complexo em qualquer banco.

---

### `db--sql-pro`
**O que é:** Especialista em SQL complexo e design de schema.

**Responsabilidades:**
- Queries complexas com múltiplos JOINs
- Window functions (ROW_NUMBER, LAG, LEAD, etc.)
- CTEs simples e recursivos
- Aggregações avançadas
- Migração entre dialetos SQL
- EXPLAIN/ANALYZE e benchmarking antes/depois

---

### `db--database-optimizer`
**O que é:** Especialista em performance de banco de dados PostgreSQL e MySQL.

**Responsabilidades:**
- Análise de query plans e gargalos
- Design e criação de índices otimizados
- Reescritas de queries para performance
- Particionamento de tabelas grandes
- Resolução de lock contention
- Tuning de configurações do PostgreSQL

**Sinergia:** Use após `db--sql-pro` — primeiro escreve a query certa, depois otimiza.

---

## dev-- → Qualidade & Processo

### `dev--python-pro`
**O que é:** Especialista em Python 3.11+ moderno com foco em qualidade, type safety e práticas de engenharia robustas.

**Responsabilidades:**
- Código Python com type annotations completas
- Configuração de mypy em strict mode
- Async/await com asyncio e padrões corretos
- Testes com pytest (fixtures, mocking, parametrize)
- Linting com black e ruff
- Dataclasses, Pydantic models, dependency injection
- Logging estruturado e error handling

---

### `dev--debugging-wizard`
**O que é:** Investigador técnico de bugs — foca em análise ativa de evidências.

**Responsabilidades:**
- Parsear e interpretar stack traces
- Correlacionar entradas de log para identificar o ponto de falha
- Traçar fluxo de execução linha a linha
- Hipóteses baseadas em evidências
- Root cause analysis

**Diferença do `superpowers:systematic-debugging`:** A skill oficial impõe **metodologia** (processo antes de propor fix). `dev--debugging-wizard` é o **investigador técnico** que abre logs e traça execução. Use os dois juntos: sistemático primeiro, wizard depois.

---

### `dev--code-reviewer`
**O que é:** Revisor de código amplo — cobre qualidade, segurança e arquitetura em uma passagem.

**Responsabilidades:**
- Identificar bugs lógicos e erros de runtime
- Detectar vulnerabilidades (SQL injection, XSS, insecure deserialization)
- Code smells e problemas de manutenibilidade
- N+1 queries e problemas de performance
- Problemas de nomenclatura e clareza
- Concerns arquiteturais
- Relatório priorizado por severidade

**Diferença do `code-review:code-review` (oficial):** O oficial tem integração nativa com GitHub (`--comment` posta inline no PR, `--fix` aplica os fixes). `dev--code-reviewer` tem análise mais detalhada. Para PRs no GitHub, prefira o oficial. Para revisão local, use este.

---

### `dev--code-refactoring`
**O que é:** Especialista em refatoração com SOLID e clean code, sem quebrar comportamento.

**Responsabilidades:**
- Identificar code smells e hotspots arriscados
- Propor plano de refatoração em passos incrementais
- Aplicar princípios SOLID (SRP, OCP, DIP...)
- Eliminar duplicação sem over-engineering
- Manter comportamento estável durante refatoração
- Atualizar testes após mudanças

---

### `dev--security-reviewer`
**O que é:** Auditor de segurança — gera relatório estruturado com severidade e remediação.

**Responsabilidades:**
- SAST (Static Application Security Testing)
- Identificar vulnerabilidades por severidade (Critical/High/Medium/Low)
- Análise de infraestrutura e configurações
- Secrets scanning
- Compliance checks (LGPD, OWASP)
- Gerar relatório com comandos de remediação

**Sinergia:** Use após `dev--code-reviewer` — review geral primeiro, depois auditoria de segurança especializada.

---

### `dev--secure-code-guardian`
**O que é:** Implementador de código seguro — age no código, não apenas audita.

**Responsabilidades:**
- Implementar hashing seguro (bcrypt, argon2)
- Sanitizar queries com parameterized statements
- Configurar CORS e CSP headers corretamente
- Validação de input com Zod (TS) ou Pydantic (Python)
- Configurar JWT tokens com segurança
- Prevenir OWASP Top 10

**Diferença de `dev--security-reviewer`:** O reviewer **identifica** problemas. O guardian **implementa** as correções. Use na sequência: reviewer → guardian.

---

### `dev--test-master`
**O que é:** Gerador completo de suites de teste — todos os tipos e camadas.

**Responsabilidades:**
- Gerar testes unitários com mocking
- Testes de integração
- Testes E2E
- Análise de cobertura e gaps
- Test plans e estratégias de QA
- Performance testing (k6, Artillery)
- Security testing (OWASP methods)
- Debugging de testes flaky

**Diferença do `superpowers:test-driven-development`:** TDD é **metodologia** (escreve teste ANTES do código). `dev--test-master` é **execução** (gera a suite de testes). Use TDD para disciplina de processo, test-master para gerar os testes em si.

---

### `dev--security-auditor`
**O que é:** Auditor de segurança de dependências npm/Node.js.

**Responsabilidades:**
- Executar `npm audit --json` e parsear o output
- Classificar CVEs por severidade (Critical → Low)
- Distinguir dependências diretas de transitivas
- Gerar relatório markdown com comandos de remediação
- Suporte a `security-exceptions.json` para riscos aceitos
- CI-friendly com exit codes corretos

**Sinergia:** Use junto de `dev--security-reviewer` (auditoria do código) + `dev--secure-code-guardian` (implementa correções). O trio cobre o ciclo completo de segurança.

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `dev--fullstack-guardian`
**O que é:** Implementador de features full-stack com segurança em todas as camadas simultaneamente.

**Responsabilidades:**
- Frontend (componente React) + Backend (endpoint FastAPI) + Banco (migration) em uma passagem
- Segurança em cada camada: auth, input validation, output encoding, parameterized queries
- Conexão de UI → API → banco de forma coesa
- CRUD com formulários conectados a endpoints reais

**Diferença de usar skills individuais:** Ao usar `fastapi-expert` + `react-expert` separadamente, você pode criar inconsistências entre camadas. `dev--fullstack-guardian` considera as três camadas ao mesmo tempo, garantindo contratos corretos.

---

## frontend-- → Frontend & UI

### `frontend--typescript-pro`
**O que é:** Especialista em TypeScript avançado — além do básico de tipos.

**Responsabilidades:**
- Generics complexos e inferência de tipos
- Conditional types e mapped types
- Branded types para type safety forte
- Type guards customizados
- Utility types (Pick, Omit, ReturnType, etc.)
- tRPC para type safety end-to-end frontend-backend
- Configuração de monorepo TypeScript

---

### `frontend--design-dna`
**O que é:** Workflow de 3 fases pra extrair, estruturar e aplicar identidade visual — design system (tokens mensuráveis), design style (percepção qualitativa) e visual effects (Canvas/WebGL/3D/shaders/scroll).

**Fonte:** [`zanwei/design-dna`](https://github.com/zanwei/design-dna) — instalada globalmente em `~/.claude/skills/frontend--design-dna/SKILL.md`

**As 3 dimensões:**
1. **design_system** — cor, tipografia, spacing, layout, shape, elevation, motion, componentes (valores exatos: hex, px, rem)
2. **design_style** — mood, linguagem visual, composição, imagery, interaction feel, brand voice (qualitativo)
3. **visual_effects** — Canvas, WebGL, 3D, partículas, shaders, scroll effects, cursor effects, glassmorphism (o que CSS puro não expressa)

**Fases:**
- **Structure** — mostra o schema completo (`references/schema.md`) quando o usuário pede a estrutura
- **Analyze** — recebe imagens/screenshots/URLs de referência e extrai um JSON Design DNA completo, campo por campo, nas 3 dimensões
- **Generate** — recebe DNA JSON + conteúdo e gera o design (`references/generation-guide.md`), escolhendo tecnologia pela intensidade do efeito (CSS/SVG leve → Canvas 2D/GSAP/Lottie médio → Three.js/GLSL/Pixi.js pesado)

**Quando usar:** "extrai o design DNA disso", "analisa esse design/screenshot/site", "gera um design a partir desse JSON", replicar estilo de uma referência em conteúdo novo.

**Diferença de `frontend-design:frontend-design`:** `frontend-design` dá direção visual geral em prosa (estética, tipografia, paleta) sem formato estruturado. `design-dna` produz **JSON estruturado e replicável** nas 3 dimensões, com pipeline extract→apply — serve pra clonar/adaptar um estilo existente com precisão, não só orientar uma escolha nova.

**Sinergia com:** `frontend-design:frontend-design` (direção quando não há referência) + `genjutsu:paint` (MASTER.md de design system pode nascer do JSON extraído) + `frontend--threejs-*`/`gsap-skills:gsap-*` (implementação dos visual_effects pesados)

---

### `frontend--motion-design`
**O que é:** Princípios de motion design pra animações e transições — timing, easing, coreografia e princípios Disney adaptados pra UI. Agnóstico de biblioteca: funciona com CSS, Framer Motion, GSAP, Lottie, Spring ou qualquer sistema de animação.

**Fonte:** [`lottiefiles/motion-design-skill`](https://github.com/lottiefiles/motion-design-skill) — instalada globalmente em `~/.claude/skills/frontend--motion-design/SKILL.md`

**Responsabilidades:**
- Três pilares obrigatórios antes de decisão técnica: Intenção Emocional, Narrativa Visual, Motion Craft
- Checklist de 8 passos (alvo emocional, personalidade de motion, propriedade primária, duração, easing, hero element, camadas secundárias, regras de 1/3)
- Tabelas de timing/easing e princípios de animação Disney aplicados a interface
- Padrões de choreography (entrance/exit, multi-elemento, ambient-continuous, state-feedback)
- Framework de decisão + checklist de qualidade + troubleshooting

**Quando usar:**
- Criar animações de UI (botões, cards, modais, transições de página)
- Micro-interações e feedback animado
- Loading/success/error states
- Sequências multi-elemento com stagger
- Estabelecer identidade de motion de marca

**Diferença de `genjutsu:cast`/`genjutsu:paint`:** `motion-design` é biblioteca de **princípios** (o quê e por quê da animação — timing, easing, narrativa). `genjutsu` é pipeline de **implementação** multi-stack (o como — código GSAP/Framer/Compose/SwiftUI, scan de stack, audit). Use `motion-design` pra fundamentar a decisão de motion, `genjutsu` pra executar tecnicamente.

**Sinergia com:** `genjutsu:cast`/`genjutsu:paint` (implementação técnica) + `frontend--ui-ux-expert` (acessibilidade/performance da UI)

---

### `frontend--threejs-*` (10 skills)
**O que é:** Coleção de referência Three.js — API precisa, exemplos funcionais e patterns de performance, auditados contra a documentação oficial (r160+).

**Fonte:** [`cloudai-x/threejs-skills`](https://github.com/cloudai-x/threejs-skills) — instaladas globalmente em `~/.claude/skills/frontend--threejs-*/SKILL.md`

| Skill | Foco |
|---|---|
| `frontend--threejs-fundamentals` | Scene, cameras, renderer, hierarquia Object3D, coordenadas |
| `frontend--threejs-geometry` | Shapes built-in, BufferGeometry, geometria custom, instancing |
| `frontend--threejs-materials` | PBR, basic/phong/standard, shader materials |
| `frontend--threejs-lighting` | Tipos de luz, sombras, environment lighting, light helpers |
| `frontend--threejs-textures` | Tipos de textura, UV mapping, environment maps, render targets |
| `frontend--threejs-animation` | Keyframe, skeletal, morph targets, animation mixing |
| `frontend--threejs-loaders` | GLTF/GLB, texturas, padrões async, caching |
| `frontend--threejs-shaders` | GLSL básico, ShaderMaterial, uniforms, efeitos custom |
| `frontend--threejs-postprocessing` | EffectComposer, bloom, DOF, screen effects, passes custom |
| `frontend--threejs-interaction` | Raycasting, camera controls, mouse/touch, seleção de objeto |

**Quando usar:** cada skill ativa pelo contexto específico — criar cena 3D aciona `fundamentals`, carregar GLTF aciona `loaders` + `animation`, efeito visual custom aciona `shaders` + `postprocessing`.

**Diferença de `genjutsu:cast` (sub-skill `threejs-r3f`):** `genjutsu` cobre **React Three Fiber** (integração React declarativa) dentro do pipeline thesis→implement→audit, carregado internamente e nunca invocado direto. `frontend--threejs-*` é **API Three.js vanilla/addons** pura, cada skill invocável e combinável independente, sem pipeline de discovery/thesis.

**Sinergia com:** `genjutsu:cast` (se o projeto usa React Three Fiber, cast cobre a camada declarativa; use threejs-* pra API de baixo nível) + `frontend--motion-design` (timing/easing de animações 3D)

---

### `frontend--ui-ux-expert`
**O que é:** Implementador de UI React acessível — 6 fases obrigatórias de processo.

**Responsabilidades (6 fases):**
1. **Estudo do Style Guide** — internalize o design system antes de qualquer código
2. **Planejamento de componentes** — mapeie hierarquia e responsabilidades
3. **Implementação** — shadcn/ui + Tailwind CSS + TanStack Query
4. **Validação de acessibilidade** — WCAG 2.1 AA obrigatório
5. **Core Web Vitals** — LCP, CLS, FID no verde
6. **Verificação de testes** — todos os E2E passando

**Diferença do `frontend-design:frontend-design`:** `frontend-design` decide **como deve parecer** (estética, tipografia, paleta). `frontend--ui-ux-expert` decide **como implementar tecnicamente** (componentes, acessibilidade, performance). Use em sequência.

---

## learn-- → Aprendizado & Descoberta

### `learn--project-mentor`
**O que é:** Guia de onboarding para qualquer repositório externo.

**Responsabilidades:**
- Explicar como um projeto está estruturado
- Mapear os principais módulos e suas interações
- Identificar padrões arquiteturais usados
- Funciona também com papers acadêmicos + código

---

### `learn--context7-docs`
**O que é:** Fetch de documentação atualizada + exemplos de código pra qualquer biblioteca, framework, SDK ou ferramenta — prioriza docs versionadas sobre training data.

**Fonte:** [`upstash/context7`](https://github.com/upstash/context7) — instalada globalmente em `~/.claude/skills/learn--context7-docs/SKILL.md`

**Responsabilidades:**
- Resolver nome da biblioteca pra ID no registry Context7
- Buscar docs versionadas (ignora training data potencialmente outdated)
- Fetch de exemplos de código, API signatures, config options
- Suportar migration guides entre versões

**Quando usar:**
- Perguntas sobre API (mesmo libs bem-conhecidas: React, Next.js, Prisma, Express, Tailwind, Django)
- Configuração de ferramenta
- Mudanças de versão ou deprecations
- Setup instructions
- CLI tool usage
- **Sempre verificar contra docs atualizadas**, não confiar em training data pra detalhes de API

**Diferença de `learn--code-teacher`:** `code-teacher` explica **código existente** (fluxo, design decisions). `context7-docs` busca **documentação oficial atualizada** pra qualquer tech (mais rápido pra lookup puro).

**Sinergia com:** `tools--context7-cli`/`tools--context7-mcp` (como a ferramenta é usada) + qualquer skill de implementação quando verificar API

---

### `learn--code-teacher`
**O que é:** Professor interativo de código — explica o que o código faz e por quê.

**Responsabilidades:**
- Explicar fluxo de execução passo a passo
- Revelar design decisions ocultas
- Identificar edge cases e comportamentos não óbvios
- Explicar impacto de mudanças em outras partes do sistema
- Ensinar debugging e raciocínio sobre o código

**Diferença de `learn--project-mentor`:** `project-mentor` explica o **projeto** (macro). `code-teacher` explica **blocos de código específicos** (micro).

---

### `learn--spec-miner`
**O que é:** Reverse engineer de codebases — extrai especificações de código sem documentação.

**Responsabilidades:**
- Mapear dependências entre módulos
- Identificar business logic não documentada
- Gerar documentação de API a partir do código-fonte
- Descobrir comportamentos implícitos e contratos ocultos
- "Code archaeology" — entender código legado

**Atenção:** Esta skill é para **extrair specs de código existente**, não para documentos textuais.

---

## tools-- → Ferramentas & Exploração

### `tools--caveman` Sistema de compressão de output
**O que é:** Modo ultra-comprimido — reduz output em ~65% usando linguagem caveman enquanto preserva precisão técnica completa.

**Responsabilidades:**
- 6 níveis de intensidade: lite, full (padrão), ultra, wenyan-lite, wenyan-full, wenyan-ultra
- Dropa artigos, preenchimento, pleasantries, hedging
- Mantém código, símbolos, strings de erro, URLs exatos
- Auto-clareza: desativa para warnings de segurança, ações irreversíveis, sequências ambíguas

**Quando usar:**
- Sessões longas quando token limit crítico
- Batch edits múltiplos arquivos
- Feedback denso de code review sem ruído

**Ativação:** Automática via hook SessionStart. Manual com `/caveman` ou "caveman mode". Desativa com "stop caveman".

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--cavecrew`
**O que é:** Guia de decisão para delegar trabalho a subagentes com output comprimido no estilo Caveman, reduzindo o custo de contexto quando o resultado do subagente volta para a thread principal.

**Responsabilidades:**
- Decidir quando usar `cavecrew-investigator`, `cavecrew-builder` ou `cavecrew-reviewer`
- Diferenciar cavecrew de agentes vanilla como `Explore` e `Code Reviewer`
- Definir contratos de output curtos e previsíveis para investigação, edição e review
- Orientar padrões de encadeamento: localizar → corrigir → revisar
- Evitar uso indevido em refactors grandes, features multi-arquivo ou feedback que precisa de prosa

**Quando usar:**
- Investigar símbolos, chamadas, arquivos e pontos de uso com baixo custo de contexto
- Fazer edição cirúrgica em até 2 arquivos já identificados
- Revisar diff com achados objetivos, sem explicação longa
- Economizar contexto em sessões longas com muita delegação

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--caveman-commit`
**O que é:** Gerador de mensagens de commit ultra-concisas em Conventional Commits.

**Responsabilidades:**
- Criar subject no formato `<type>(<scope>): <summary>`
- Manter subject preferencialmente com até 50 caracteres
- Escrever corpo só quando o motivo não é óbvio, há breaking change, migração, segurança ou revert
- Evitar ruído como "this commit", atribuição a IA, emoji e repetição de nomes de arquivo
- Produzir mensagem pronta em bloco de código, sem executar `git commit`

**Quando usar:**
- Escrever mensagem de commit
- Gerar commit message a partir de diff staged/unstaged
- Padronizar commits com `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, etc.

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--caveman-compress`
**O que é:** Compressor de arquivos de memória/prosa (`CLAUDE.md`, todos, preferences, `.md`, `.txt`) para reduzir tokens preservando conteúdo técnico.

**Responsabilidades:**
- Comprimir texto natural removendo filler, hedging, redundância e pleasantries
- Preservar exatamente code blocks, inline code, URLs, comandos, paths, números e frontmatter
- Manter estrutura Markdown: headings, listas, tabelas e hierarquia
- Criar backup human-readable como `<arquivo>.original.md`
- Validar saída e evitar sobrescrever se a compressão falhar

**Quando usar:**
- Reduzir custo de contexto de arquivos de memória longos
- Compactar documentação operacional repetitiva
- Preparar `CLAUDE.md` ou preferências para sessões com limite de tokens apertado

**Atenção:** não usar em código, JSON, YAML, TOML, `.env`, lockfiles, CSS, HTML, SQL ou shell scripts.

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--caveman-help`
**O que é:** Cartão de referência rápida dos modos, comandos e skills Caveman.

**Responsabilidades:**
- Exibir modos `lite`, `full`, `ultra`, `wenyan-lite`, `wenyan-full`, `wenyan-ultra`
- Listar comandos `/caveman`, `/caveman-commit`, `/caveman-review`, `/caveman-compress`, `/caveman-help`
- Explicar como desativar com "stop caveman" ou "normal mode"
- Documentar configuração de modo padrão via `CAVEMAN_DEFAULT_MODE` ou `~/.config/caveman/config.json`

**Quando usar:**
- Lembrar os comandos disponíveis
- Ver opções de intensidade
- Descobrir como ativar, desativar ou configurar Caveman

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--caveman-review`
**O que é:** Formato de code review ultra-conciso: uma linha por achado com localização, problema e correção.

**Responsabilidades:**
- Produzir comentários no formato `L<linha>: <problema>. <fix>.`
- Usar severidades opcionais: bug, risk, nit e q
- Remover hedging e preâmbulos de review
- Preservar símbolos, funções e variáveis exatos em backticks
- Sair do modo terse quando segurança, arquitetura ou onboarding exigirem explicação completa

**Quando usar:**
- Revisar PR/diff com comentários prontos para colar
- Gerar feedback objetivo e denso
- Reduzir ruído em revisões repetitivas

**Limite:** não aplica fixes, não aprova PR e não executa linters.

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--caveman-stats`
**O que é:** Skill acionada por hook para mostrar uso real de tokens e economia estimada da sessão atual.

**Responsabilidades:**
- Ler estatísticas reais do log de sessão do Claude Code
- Exibir números via hook `caveman-mode-tracker`
- Bloquear a resposta do modelo e mostrar o resultado calculado pelo hook
- Evitar estimativa manual pelo LLM

**Quando usar:**
- Rodar `/caveman-stats`
- Verificar economia de tokens durante uma sessão longa
- Auditar impacto real do modo Caveman

**Status GitHub:** local-only por enquanto — não aparece em `origin/main`.

---

### `tools--context7-cli` e `tools--context7-mcp`
**O que é:** Ferramentas CLI e MCP do Context7 pra fetch de documentação atualizada e gerenciamento de skills.

**Fonte:** [`upstash/context7`](https://github.com/upstash/context7) — instaladas globalmente em `~/.claude/skills/tools--context7-*/SKILL.md`

**`tools--context7-cli` — ctx7 CLI:**
- Fetch de docs versionadas pra qualquer biblioteca (resolve library ID → query docs)
- Gerenciar skills (install/search/suggest/list/remove/generate)
- Setup de Context7 MCP pra Claude Code/Cursor/OpenCode
- Quando usar: documentação desatualizada, verificar API signatures, setup MCP

**`tools--context7-mcp` — Context7 MCP Server:**
- Protocol MCP pra integrar Context7 como ferramenta nativa do agente
- Fetch docs, gerenciar skills, listar bibliotecas
- Quando usar: setup MCP, usar context7 via MCP dentro do agente

**Diferença de `learn--context7-docs`:** `context7-cli`/`context7-mcp` ensinam **como usar a ferramenta**. `context7-docs` é o workflow de **lookup de docs** pra qualquer biblioteca (mais alto nível, usa CLI internamente).

**Sinergia com:** `learn--context7-docs` (workflow de lookup) + qualquer skill de implementação (quando precisa verificar API desatualizada)

---

### `tools--graphify`
**O que é:** Transforma qualquer pasta de arquivos em grafo de conhecimento navegável com detecção de comunidades, auditoria de mudanças e três saídas: HTML interativo, JSON pronto para GraphRAG e relatório legível em Markdown.

**Propósito central:** Responder perguntas sobre a arquitetura e relacionamentos de arquivos de um codebase — especialmente quando `tools--graphify-out/` existe, questões devem ser tratadas como queries do tools--graphify primeiro.

**Responsabilidades:**
- Gerar grafo de conhecimento persistente do codebase (`tools--graphify-out/graph.json`)
- Criar visualização interativa HTML com comunidades detectadas
- Fornecer três ferramentas de query para exploração:
  - `tools--graphify query "<pergunta>"` — retorna subgrafo relevante
  - `tools--graphify path "<A>" "<B>"` — mostra relacionamentos entre conceitos
  - `tools--graphify explain "<conceito>"` — explica conceitos focados
- Gerar `GRAPH_REPORT.md` com análise de arquitetura
- Manter grafo atualizado com `tools--graphify update .` (incremental, AST-only)
- Suportar entrada múltipla (arquivos locais, GitHub repos, papers + código)

**Quando usar:**
1. **Entender arquitetura de um codebase** — use query/path/explain para navegação rápida
2. **Responder perguntas técnicas sobre o projeto** — codebase questions → tools--graphify query ANTES de grep/read bruto
3. **Analisar relacionamentos entre módulos** — entender acoplamentos, dependências cruzadas, comunidades
4. **Onboarding em repositório novo** — construir grafo, ler `GRAPH_REPORT.md`, depois codebase é navegável
5. **Arquivos modificados recentemente** — `tools--graphify update .` mantém o grafo sincronizado com mudanças de código

**Como usar:**
```bash
# Pipeline completo (gera HTML + JSON + GRAPH_REPORT.md)
tools--graphify                                           # codebase atual
tools--graphify <caminho>                                 # pasta específica
tools--graphify https://github.com/<owner>/<repo>        # clonar repo e processar
tools--graphify <repo1> <repo2> ...                       # múltiplos repos com merge

# Modos e opções
tools--graphify <caminho> --mode deep                    # extração richer com mais inferências
tools--graphify <caminho> --update                       # incremental - só novos/alterados
tools--graphify <caminho> --directed                     # grafo direcionado (preserva A→B)
tools--graphify <caminho> --cluster-only                 # reclusterizar grafo existente
tools--graphify <caminho> --no-viz                       # JSON + report, pula visualização
```

**Outputs:**
- `tools--graphify-out/` → diretório com todos os resultados
- `tools--graphify-out/index.html` → visualização interativa (abrir no browser)
- `tools--graphify-out/graph.json` → JSON para uso programático ou GraphRAG
- `tools--graphify-out/GRAPH_REPORT.md` → análise legível de arquitetura
- `tools--graphify-out/wiki/` → índice de navegação (se `--obsidian` usado)

**Regras ao usar:**
1. Se `tools--graphify-out/graph.json` existe, sempre use `query/path/explain` para codebase questions ANTES de grep/read
2. Se `tools--graphify-out/wiki/index.md` existe, use para navegação ampla ao invés de browsar fonte bruto
3. Após modificações de código, rodar `tools--graphify update .` mantém o grafo consistente (AST-only, sem custo de API)
4. Use `GRAPH_REPORT.md` para análise arquitetural ampla quando query/path/explain insuficientes

**Sinergia com:** `learn--project-mentor` (understand project structure) + `learn--spec-miner` (reverse-engineer code) + `dev--code-reviewer` (entender impacto arquitetural de mudanças)

---

## n8n-- → Automação N8N

> Skills oficiais do n8n — fonte: [`n8n-io/skills`](https://github.com/n8n-io/skills). **Regra central:** invocar a skill correspondente **antes** de qualquer ação no n8n — o MCP do n8n evolui mais rápido que o training cutoff de qualquer modelo.

### `n8n--using-skills` Meta-skill roteadora
**O que é:** Protocolo sempre ativo — roteia para a skill correta e estabelece regras transversais.

**Regras não-negociáveis:**
1. Invocar skill relevante ANTES de qualquer ação n8n
2. `validate_workflow` antes de publicar + `get_workflow_details` após criar/atualizar
3. Tokens e secrets **nunca** em campos de texto — usar sistema de credenciais do n8n

### Demais skills n8n

| Skill | Foco |
|---|---|
| `n8n--workflow-lifecycle` | Design, estrutura e publicação de workflows |
| `n8n--node-configuration` | Config de nós (HTTP, webhooks, banco, Slack/Gmail, AI, triggers) |
| `n8n--expressions` | Expressões `{{...}}`, referências `$json`/`$node`, Luxon |
| `n8n--loops` | Processar múltiplos itens, batches, paginação, fan-out |
| `n8n--subworkflows` | Modularização e reuso de lógica |
| `n8n--error-handling` | Tratamento de erros, error workflows, try/catch |
| `n8n--agents` | AI Agents, LLM chains, RAG, embeddings, structured output |
| `n8n--credentials-and-security` | Autenticação, OAuth, API keys, secrets |
| `n8n--code-nodes` | Code node JavaScript/Python, transformações com `$input`/`$json` |
| `n8n--data-tables` | Data Tables, idempotência, dedup, estado cross-execução |
| `n8n--binary-and-data` | Arquivos, PDFs, multimodal, upload/download |
| `n8n--debugging` | Investigação de workflows com erro ou output inesperado |
| `n8n--extending-mcp` | Expor workflows n8n como tools MCP para agentes |

### `n8n--workflow-lifecycle`
**O que é:** Skill de ciclo de vida completo de workflows n8n — planejar, construir, validar, testar, publicar e fazer handoff.

**Responsabilidades:**
- Definir estrutura visual, nomes, descrições e organização do workflow
- Aplicar as etapas PLAN → BUILD → VALIDATE → TEST → PUBLISH → HANDOFF
- Rodar `validate_workflow` e conferir `connections` com `get_workflow_details`
- Tratar limitações de folders, projetos e acesso MCP
- Evitar publicar sem teste representativo e sem verificação das credenciais

**Quando usar:** qualquer criação, edição, organização, publicação, deploy ou validação final de workflow n8n.

---

### `n8n--node-configuration`
**O que é:** Especialista em configurar nós n8n com parâmetros corretos, dependências entre campos e operações suportadas.

**Responsabilidades:**
- Consultar tipos de nós e parâmetros reais antes de configurar
- Configurar HTTP, Webhook, banco, comunicações, AI, triggers, Merge e Switch
- Evitar assumir nomes de parâmetros ou defaults
- Validar configurações de nós individualmente quando necessário
- Tratar casos especiais como Merge com múltiplas entradas e fallback de Switch

**Quando usar:** sempre que criar ou alterar qualquer node no workflow.

---

### `n8n--expressions`
**O que é:** Especialista em expressões n8n `{{ ... }}`, `$json`, `$node`, Luxon e transformações inline.

**Responsabilidades:**
- Escrever expressões corretas para campos dinâmicos
- Usar `$json`, `$input`, `$node` e dados de execuções anteriores corretamente
- Fazer date math e formatação com Luxon
- Preferir expressions/Edit Fields quando não há necessidade real de Code node
- Depurar erros de expressão e referências quebradas

**Quando usar:** qualquer campo com `{{...}}`, mapeamento dinâmico, transformação simples ou erro de expressão.

---

### `n8n--loops`
**O que é:** Guia para processar múltiplos itens, batches, paginação e padrões de repetição no n8n.

**Responsabilidades:**
- Diferenciar iteração automática por item de Loop Over Items explícito
- Configurar batches e paginação HTTP
- Evitar loops desnecessários quando o node já processa item-a-item
- Projetar fan-out e execução assíncrona com subworkflows quando fizer sentido
- Tratar agregação e recombinação de resultados

**Quando usar:** listas, batches, paginação, "for each", processamento em massa ou fan-out.

---

### `n8n--subworkflows`
**O que é:** Skill de modularização e reuso de lógica via subworkflows.

**Responsabilidades:**
- Decidir quando extrair lógica para subworkflow
- Definir contratos de input/output com `Execute Workflow Trigger`
- Usar `Define Below` quando subworkflow virar tool de agent ou MCP
- Nomear subworkflows para descoberta futura
- Separar contratos divergentes, como JSON vs binary ou sync vs async

**Quando usar:** lógica reutilizável, chunks com mais de alguns nós, ferramentas para agents, ou workflow que precisa virar módulo.

---

### `n8n--error-handling`
**O que é:** Especialista em tratamento de erros para workflows de produção.

**Responsabilidades:**
- Criar branches de erro em nodes falíveis
- Definir error workflows e respostas HTTP adequadas
- Separar erros do caller (4xx) de falhas internas (5xx)
- Padronizar shapes de resposta de erro
- Validar comportamento quando APIs, bancos ou serviços externos falham

**Quando usar:** workflows publicados, webhooks, integrações externas ou qualquer fluxo que precisa falhar de forma controlada.

---

### `n8n--agents`
**O que é:** Especialista em features de IA no n8n: AI Agent, LLM chains, tool calling, memória, RAG e structured output.

**Responsabilidades:**
- Escolher entre Agent, Basic LLM Chain, Text Classifier, Information Extractor e outros nodes LangChain
- Configurar model, memory, tools e output parser como subnodes
- Escrever nomes e descrições de tools como parte do prompt
- Usar structured output com parser e auto-fix
- Modelar subworkflows como tools com inputs tipados via `fromAi()`

**Quando usar:** agent, chat assistant, LLM com tools, system prompt, memory, RAG, embeddings, output parser ou qualquer node `@n8n/n8n-nodes-langchain.*`.

---

### `n8n--credentials-and-security`
**O que é:** Skill de autenticação, credenciais e segurança em workflows n8n.

**Responsabilidades:**
- Usar o sistema de credenciais para tokens, API keys, OAuth e senhas
- Nunca colocar secrets em campos de texto, Set nodes ou código
- Listar credenciais existentes e vincular por ID quando possível
- Orientar criação manual de credenciais quando o MCP não puder criá-las
- Tratar secrets colados no chat como comprometidos e recomendar rotação

**Quando usar:** API key, bearer token, OAuth, headers de auth, serviços externos ou qualquer configuração com segredo.

---

### `n8n--code-nodes`
**O que é:** Guia para decidir quando usar Code node e como escrever JavaScript/Python em n8n.

**Responsabilidades:**
- Tratar Code node como último recurso
- Preferir expression ou arrow function em Edit Fields para transformações simples
- Usar JavaScript por padrão, Python só quando explicitamente pedido
- Aplicar padrões corretos para `$input`, `$json`, múltiplas fontes e retorno de itens
- Evitar lógica opaca que poderia ser representada por nodes nativos

**Quando usar:** Code node, JavaScript/Python, custom logic, transformações complexas ou tentação de "resolver no código".

---

### `n8n--data-tables`
**O que é:** Especialista em Data Tables do n8n para estado persistente, deduplicação e dados tabulares simples.

**Responsabilidades:**
- Projetar schemas com colunas padrão e tipos suportados
- Modelar dedup, idempotência e estado cross-execução
- Evitar usar Data Tables como banco relacional completo
- Trabalhar com limitações de tipos, chaves e relacionamentos
- Mapear operações CRUD dentro de workflows

**Quando usar:** Data Tables, armazenamento simples, dedup, idempotência, estado persistente ou tabelas internas do n8n.

---

### `n8n--binary-and-data`
**O que é:** Skill para arquivos, imagens, anexos e dados binários em n8n.

**Responsabilidades:**
- Diferenciar dados JSON em `$json` de arquivos em `$binary`
- Configurar upload, download, anexos e leitura de buffers
- Preservar binary data com Merge quando etapas intermediárias removem contexto
- Lidar com limites entre Agent tools e binary data
- Usar storage/URLs quando arquivos precisam atravessar fronteiras JSON-only

**Quando usar:** arquivo, imagem, PDF, attachment, upload, download, multimodal, vision ou agent tool que precisa receber/retornar arquivo.

---

### `n8n--debugging`
**O que é:** Investigador de workflows n8n com erro, output inesperado ou comportamento diferente do esperado.

**Responsabilidades:**
- Conferir parâmetros reais de nodes e execuções
- Investigar validação que passa mas workflow quebra em runtime
- Buscar fonte do n8n quando comportamento não estiver claro
- Diagnosticar erros de expressão, conexões, credenciais e shapes de dados
- Transformar sintomas em hipóteses testáveis

**Quando usar:** "não funciona", erro em execução, output vazio, node pulado, parâmetro ignorado ou comportamento estranho.

---

### `n8n--extending-mcp`
**O que é:** Guia para expor workflows n8n como tools MCP quando o MCP atual não cobre uma capacidade necessária.

**Responsabilidades:**
- Identificar lacunas do MCP nativo
- Criar workflows-tool com contratos claros
- Expor operações n8n para agentes externos
- Garantir permissões e segurança antes de automatizar ações sensíveis
- Documentar inputs, outputs e limitações da tool exposta

**Quando usar:** quando uma capacidade precisa existir como tool MCP e não há ferramenta nativa suficiente.

---

## product-- → Produto & Análise

### `product--product-discovery`
**O que é:** Validador de oportunidades de produto antes de commitar recursos.

**Responsabilidades:**
- Mapear hipóteses e suposições
- Planejar discovery sprints
- Testar problem-solution fit
- Identificar riscos de produto antes de construir
- Frameworks de priorização (RICE, ICE)

---

### `product--generic-feature-developer`
**O que é:** Guia de desenvolvimento de features com padrões de arquitetura por tipo de projeto.

**Responsabilidades:**
- Fluxo: Entender → Planejar → Implementar → Testar
- Padrões de arquitetura por tipo (React/Next.js, FastAPI, automação)
- Boas práticas integradas no fluxo
- Orientação contextual sem ser stack-específico

---

### `product--feature-forge`
**O que é:** Workshop de requisitos — transforma ideias em especificações formais de produto.

**Responsabilidades:**
- Conduzir workshops estruturados de requisitos
- Escrever user stories no formato correto
- EARS format (Event-driven, Attribute-driven, etc.)
- Acceptance criteria objetivos e testáveis
- Implementation checklists
- PRDs (Product Requirements Documents)
- Matrizes de requisitos

**Sinergia:** `product--product-discovery` → `product--feature-forge` → `arch--api-designer` → implementação.

---

### `product--project-planner`
**O que é:** Planejador de projetos gerais — não técnico, focado em gestão e estratégia.

**Responsabilidades:**
- Definir metas e milestones (SMART goals, OKRs)
- Criar roadmaps e timelines
- Gantt charts
- Planejamento de recursos
- Avaliação de riscos e contingências
- Planos para negócios, eventos, projetos acadêmicos e pessoais

**Diferença de `superpowers:writing-plans`:** `writing-plans` planeja **implementação técnica** de software. `product--project-planner` planeja **projetos gerais** (não técnicos).

---


## Skills Oficiais Anthropic (Superpowers)

> Ficam em `~/.claude/plugins/cache/claude-plugins-official/superpowers/`
> **Não editar.** São atualizadas automaticamente pelo sistema de plugins.
> Ativação: **automática** — o Claude Code as chama sem você pedir.

| Skill | Quando ativa automaticamente | Para que serve |
|---|---|---|
| `brainstorming` | Antes de criar features, componentes ou modificar comportamento | Explora intenção e design antes do código |
| `writing-plans` | Quando há spec/requisitos de tarefa multi-step | Gera plano de implementação passo a passo |
| `executing-plans` | Quando há um plano escrito para executar em sessão separada | Executa com checkpoints de revisão |
| `systematic-debugging` | Ao encontrar qualquer bug, falha de teste ou comportamento inesperado | Impõe metodologia antes de propor fix |
| `test-driven-development` | Antes de escrever código de implementação | Garante que o teste exista antes do código |
| `requesting-code-review` | Ao completar tarefas ou implementar features | Prepara e verifica o trabalho antes do review |
| `receiving-code-review` | Ao receber feedback de review | Avalia sugestões criticamente antes de aplicar |
| `verification-before-completion` | Antes de declarar algo pronto, fixado ou passando | Exige evidência antes de qualquer afirmação |
| `finishing-a-development-branch` | Quando implementação completa e testes passando | Guia merge/PR/cleanup |
| `dispatching-parallel-agents` | 2+ tarefas independentes sem estado compartilhado | Paraleliza trabalho via subagentes |
| `subagent-driven-development` | Executar planos com tarefas independentes na sessão atual | Desenvolvimento via múltiplos subagentes |
| `using-git-worktrees` | Antes de feature work que precisa de isolamento | Cria workspace isolado via git worktree |

### Outros Plugins Oficiais

| Plugin | Tipo | Para que serve |
|---|---|---|
| `code-review:code-review` | Skill | Review de PR ou diff local — `--comment` posta inline no GitHub, `--fix` aplica fixes |
| `frontend-design:frontend-design` | Skill | Direção visual: estética, tipografia, escolhas de design não-genéricas |
| `skill-creator:skill-creator` | Skill | Criar, editar, testar e otimizar novas skills |
| `code-simplifier` | Agente | Simplifica e refina código recém-modificado automaticamente |

---

## marketing-- → Marketing & Growth

> 49 skills de marketing e crescimento (Corey Haines). Padronizadas com prefixo `marketing--*` (domínio especializado separado de `product--`).

**Fonte:** [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills)

**Cobertura (algumas das principais):**
- **SEO:** seo-audit, ai-seo, schema, programmatic-seo, site-architecture
- **Paid Ads:** ads, ad-creative, attribution, analytics, aso (App Store)
- **Copy:** copywriting, copy-editing, cold-email, emails, sms, social
- **Conversion:** cro (conversion-rate-optimization), paywalls, popups, pricing, offers
- **Content:** content-strategy, free-tools, image, video, schema
- **Growth:** ab-testing, launch, product-marketing, referrals, onboarding, churn-prevention, lead-magnets
- **Research:** customer-research, competitor-profiling, competitors
- **Revenue:** revops, sales-enablement, public-relations, influencer-marketing
- **Misc:** community-marketing, co-marketing, marketing-council, marketing-ideas, marketing-loops, marketing-psychology, directory-submissions, prospecting

**Quando usar:** qualquer tarefa de marketing — from brand strategy (marketing-plan) até execution (copywriting, ads, analytics, revops).

**Nota:** skills são altamente especializadas — referem-se umas às outras pra coordenação (e.g., copywriting remete pra emails pra cold-email copy vs website copy).

---

## composio-- → Suites de Utilidade Geral

> 27 skills genéricas de utilidade (Composio HQ) — design, content, dev tooling, integrations, research. **NÃO são ferramentas Composio reais**, mas skills de propósito geral que pertencem a um domínio próprio, fora de `product--`, `dev--`, etc. Padronizadas com prefixo único `composio--*` pra evitar poluição de categorias de engenharia.

**Fonte:** [`ComposioHQ/awesome-claude-skills`](https://github.com/ComposioHQ/awesome-claude-skills)

| Tipo | Skills |
|---|---|
| **UI/Design** | artifacts-builder, brand-guidelines, canvas-design, theme-factory |
| **Content/Writing** | content-research-writer, internal-comms, changelog-generator |
| **Dev Tooling** | webapp-testing, langsmith-fetch, skill-creator, skill-share |
| **Integrations** | connect, connect-apps (Gmail, Slack, GitHub, Notion, 1000+ services) |
| **Data/Analysis** | lead-research-assistant, competitive-ads-extractor, developer-growth-analysis, meeting-insights-analyzer, twitter-algorithm-optimizer |
| **Utilities** | video-downloader, image-enhancer, domain-name-brainstormer, file-organizer, raffle-winner-picker |

**Padrão de categorização:** Estas são skills **GENÉRICAS e AGNÓSTICAS** (não se especializam em domínio como marketing, dev, data — são utilitários). Por isso ficam em categoria própria `composio--*`, não espalhadas por `dev--composio-*`, `product--composio-*`, etc.

---

## Plugins de Terceiros

> Instalados via marketplace de plugin (`claude plugin marketplace add` + `claude plugin install`), não por cópia manual em `~/.claude/skills/`. Ficam em `~/.claude/plugins/cache/<marketplace>/`, atualizados pelo próprio sistema de plugins.

### `genjutsu:cast` e `genjutsu:paint`
**O que é:** Plugin de creative coding para motion design, micro-interações e sistemas visuais — cobre Web (React/Vue/Svelte, GSAP, Framer Motion, CSS nativo, Three.js, Canvas generativo), Android (Jetpack Compose, Compose Multiplatform) e Apple (SwiftUI iOS/macOS).

**Fonte:** [`AThevon/genjutsu`](https://github.com/AThevon/genjutsu) — instalado via `claude plugin marketplace add https://github.com/AThevon/genjutsu.git` + `claude plugin install genjutsu@genjutsu`.

**Estrutura:** dois orquestradores (`cast`, `paint`) carregam dinamicamente 15 sub-skills internas em `_jutsu/` (nunca invocadas diretamente) conforme stack detectado e escopo do pedido. Resolução de caminho via `${CLAUDE_PLUGIN_ROOT}` — por isso instalado como plugin real, não copiado manualmente como `tools--graphify`/`tools--caveman`.

**`genjutsu:cast` — The Illusionist:**
- Pipeline: Scan stack → Evaluate scope → Propõe interaction thesis → Load sub-skills → Implement → Mini-audit
- Uso: efeito isolado, animação pontual, polish de interação existente (ex: "adiciona scroll animation nessa seção", "deixa esse dropdown mais snappy")

**`genjutsu:paint` — The Master Painter:**
- Pipeline: Brainstorm → Define visual + interaction thesis → Gera design system persistente (`MASTER.md`/`Theme.kt`/`Color+App.swift`) → Implement → Full audit
- Uso: redesign completo, sistema de design do zero (ex: "redesenha a landing page inteira", "monta um portfólio do zero")

**Regras do plugin (Iron Rules):**
- Nunca codar sem interaction thesis validada pelo usuário
- Uma pergunta por vez na fase de discovery, nunca em lote
- Rejeita AI slop genérico (gradiente arco-íris, glassmorphism gratuito, "moderno e clean")
- Nunca instala dependência sem perguntar
- Complexidade proporcional ao escopo (hover effect não justifica GSAP + ScrollTrigger)

**Diferença de `frontend-design:frontend-design`:** `frontend-design` decide direção visual geral (estética, tipografia, paleta). `genjutsu:paint`/`cast` implementam tecnicamente motion e interação, com pipeline próprio de thesis + audit multi-stack (web/Compose/SwiftUI), incluindo Android e Apple nativos que `frontend-design` não cobre.

**Sinergia com:** `frontend-design:frontend-design` (direção visual antes) + `frontend--ui-ux-expert` (implementação React/acessibilidade) + `dev--test-master` (testes de componente/regressão visual)

---

### `gsap-skills:gsap-*` (8 skills)
**O que é:** Skills oficiais GreenSock — API GSAP completa: core, timelines, ScrollTrigger, plugins, React, outros frameworks, performance e utils.

**Fonte:** [`greensock/gsap-skills`](https://github.com/greensock/gsap-skills) — instalado via `claude plugin marketplace add https://github.com/greensock/gsap-skills.git` + `claude plugin install gsap-skills@gsap-skills`.

| Skill | Foco |
|---|---|
| `gsap-core` | `gsap.to/from/fromTo`, easing, duration, stagger, defaults, `matchMedia()` (responsivo/reduced-motion) |
| `gsap-timeline` | `gsap.timeline()`, position parameter, nesting, playback |
| `gsap-scrolltrigger` | Scroll-linked animation, pinning, scrub, triggers, parallax |
| `gsap-plugins` | ScrollToPlugin, ScrollSmoother, Flip, Draggable, Inertia, Observer, SplitText, ScrambleText, SVG, CustomEase e afins |
| `gsap-react` | `useGSAP` hook, refs, `gsap.context()`, cleanup |
| `gsap-frameworks` | Vue, Svelte, Nuxt, SvelteKit — lifecycle, scoping, cleanup on unmount |
| `gsap-performance` | Transforms vs layout thrashing, `will-change`, batching, 60fps |
| `gsap-utils` | `gsap.utils`: clamp, mapRange, normalize, interpolate, random, snap, toArray, wrap, pipe |

**Nota:** GSAP e todos os plugins (SplitText, MorphSVG, etc.) são 100% gratuitos desde a aquisição pelo Webflow — sem Club membership, sem registry privado.

**Diferença de `genjutsu:cast` (sub-skill `gsap`):** `genjutsu` cobre GSAP dentro do pipeline thesis→implement→audit multi-stack, carregado internamente. `gsap-skills` é API GSAP standalone, cada skill invocável direto, sem pipeline de discovery.

**Sinergia com:** `genjutsu:cast` (pipeline de implementação) + `frontend--motion-design` (timing/easing/narrativa antes de escrever timeline)

---

## Ferramentas Per-Project (não instaladas globalmente)

> Skills que dependem de um app/scaffold companion rodando dentro do projeto (dev server, player, banco de arquivos específico). Não fazem sentido em `~/.claude/skills/` porque a skill sozinha, sem o app companion, não funciona — instalar globalmente criaria uma skill que ativa mas quebra na hora de executar.

### `text-to-lottie`
**O que é:** Framework pra gerar animações Lottie/Bodymovin JSON production-ready com verificação ao vivo num player Skia Skottie local (Vite + React).

**Fonte:** [`diffusionstudio/lottie`](https://github.com/diffusionstudio/lottie)

**Por que não é skill global:** a skill assume a existência de "the official player project" — um app Vite/React que o próprio repo é. Cenas são lidas/escritas em `public/projects/<projeto>/<scene-N>/lottie.json` dentro desse app, com dev server rodando pra preview live (`?frame=N`). Sem esse scaffold, a skill não tem onde escrever nem como verificar o resultado.

**Como usar quando precisar:** dentro do projeto específico que vai gerar Lottie (não neste repo de skills globais), rodar:
```bash
npx skills add diffusionstudio/lottie
```
Isso instala a skill `text-to-lottie` e o player app naquele projeto. Depois pedir ao agente pra gerar a animação — ele resolve o SVG/dados de entrada, escreve o JSON na cena e valida no player.

**Responsabilidades (quando ativa num projeto):**
- Roteamento por tipo de pedido (logo, tipografia, lower-third, loader/ícone, microinteração, diagrama técnico, dados/stats, promo, efeitos visuais) pra referência específica
- Defaults de design restritivo ("premium = subtrair, não adicionar" — zero chrome/card/borda por padrão)
- Regras de cena: slots editáveis, `controls.json`, texto nativo Lottie com fonte embutida, easing não-linear obrigatório
- Verificação: valida JSON, roda dev server, inspeciona frames exatos antes de finalizar

**Sinergia com:** `frontend--motion-design` (timing/easing/princípios que fundamentam a animação antes de virar JSON)

---

## Fluxos de Sinergia

### Feature Nova (do zero ao PR)
```
product--product-discovery    → vale construir?
product--feature-forge        → user story + acceptance criteria
arch--api-designer            → contrato da API
[brainstorming]               → (automático) explora design
writing-plans                 → (automático) plano de implementação
test-driven-development       → (automático) teste antes do código
dev--test-master              → suite completa
dev--fullstack-guardian       → implementação full-stack segura
verification-before-completion → (automático) prova antes de afirmar
requesting-code-review        → (automático) prepara para review
code-review:code-review       → executa o review
finishing-a-development-branch → merge/PR
```

### Bug Investigation
```
systematic-debugging    → (automático) metodologia primeiro
dev--debugging-wizard   → investigação técnica ativa
[skill da camada]       → fix na camada correta
verification-before-completion → (automático) prova o fix
dev--test-master        → teste de regressão
```

### Nova UI / Tela
```
frontend-design:frontend-design  → direção visual
frontend--ui-ux-expert           → 6 fases de implementação
frontend--typescript-pro         → tipagem avançada
dev--test-master                 → testes de componente
playwright-expert (projeto)      → testes E2E
```

### Qualidade antes de Merge
```
dev--code-reviewer        → revisão ampla
dev--security-reviewer    → auditoria de segurança
dev--secure-code-guardian → implementa correções
dev--security-auditor     → dependências npm
dev--code-refactoring     → refatora pontos problemáticos
code-simplifier (agente)  → simplifica resultado
```

### Banco de Dados com Performance
```
arch--api-designer      → define contratos antes do schema
db--postgres-pro        → modela schema com features Postgres
db--sql-pro             → escreve queries complexas
db--database-optimizer  → otimiza após EXPLAIN ANALYZE
```

### Exploração e Compreensão de Codebase
```
tools--graphify                   → gera grafo persistente + visualização
tools--graphify query/path/explain → navega o grafo para perguntas rápidas
learn--project-mentor      → onboarding estruturado do projeto
learn--code-teacher        → entender blocos de código específicos
learn--spec-miner          → reverse-engineer logic não documentada
dev--code-reviewer         → entender impacto arquitetural de mudanças
```

### Automação N8N (workflow do zero ao deploy)
```
n8n--using-skills         → (sempre ativo) protocolo e roteamento
n8n--workflow-lifecycle   → design, estrutura e organização do workflow
n8n--node-configuration   → configuração dos nós
n8n--expressions          → expressões {{...}} e $json
n8n--subworkflows         → modularizar lógica repetível
n8n--error-handling       → branches de erro e workflows de produção
n8n--credentials-and-security → autenticação e secrets
n8n--agents               → se houver IA/LLM no workflow
n8n--loops                → processar múltiplos itens ou páginas
n8n--debugging            → quando algo não funciona
```

### Novos Agentes
```
ai--multi-agent-architect → quando for um time de agentes: taxonomia, padrões, fronteiras
ai--agno                  → padrões idiomáticos do framework (API, estrutura, regras)
ai--prompt-engineer       → escreve o system prompt
ai--agent-development     → estrutura o agente no Claude Code (frontmatter, tools)
dev--python-pro           → implementa a lógica Python
ai--rag-architect         → se o agente precisar buscar contexto no pgvector
dev--test-master          → testes do agente
```

---

## Referência Rápida

| Situação | Skill(s) |
|---|---|
| Criar feature nova | `brainstorming` → `product--feature-forge` → `writing-plans` |
| Bug apareceu | `systematic-debugging` → `dev--debugging-wizard` |
| Review de PR | `code-review:code-review --comment` |
| Review local | `dev--code-reviewer` |
| Segurança antes de subir | `dev--security-reviewer` → `dev--secure-code-guardian` |
| Auditoria npm | `dev--security-auditor` |
| Nova tela UI | `frontend-design` → `frontend--ui-ux-expert` |
| Motion/micro-interação pontual | `genjutsu:cast` |
| Redesign completo / design system do zero | `genjutsu:paint` |
| Fundamentar timing/easing/narrativa de uma animação | `frontend--motion-design` |
| Cena/geometria/shader/GLTF Three.js | `frontend--threejs-*` (skill específica pelo contexto) |
| Timeline/ScrollTrigger/plugin GSAP | `gsap-skills:gsap-*` (skill específica pelo contexto) |
| Extrair/clonar estilo de referência (imagem/URL) | `frontend--design-dna` |
| Gerar Lottie JSON (dentro de projeto com player) | `text-to-lottie` (`npx skills add diffusionstudio/lottie`) |
| TypeScript complexo | `frontend--typescript-pro` |
| Python moderno | `dev--python-pro` |
| Query lenta | `db--database-optimizer` + `db--sql-pro` |
| Criar agentes | `ai--agent-development` + `ai--prompt-engineer` |
| Criar agente com Agno (único) | `ai--agno` → `ai--prompt-engineer` + `ai--agent-development` |
| Criar time de agentes | `ai--multi-agent-architect` → `ai--agent-development`/`ai--agno` → `ai--prompt-engineer` |
| Entender lib externa | `learn--project-mentor` |
| Fetch docs atualizadas de qualquer lib | `learn--context7-docs` |
| Entender trecho de código | `learn--code-teacher` |
| Código sem documentação | `learn--spec-miner` |
| Pergunta sobre codebase | `tools--graphify` (query/path/explain) |
| Explorar arquitetura do projeto | `tools--graphify query` (se tools--graphify-out/ existir) |
| Onboarding em novo repo | `tools--graphify` → ler GRAPH_REPORT.md → `learn--project-mentor` |
| Escrever testes | `test-driven-development` + `dev--test-master` |
| Pronto para commitar | `verification-before-completion` (automático) |
| Criar PR | `requesting-code-review` → `finishing-a-development-branch` |
| Recebeu feedback de review | `receiving-code-review` |
| Dados → relatório | `data--pandas-pro` → `data--storyteller` |
| Browser automation / web scraping / UI test | `arch--browserbase-*` (skill específica pelo contexto) |
| Deploy / Docker | `arch--devops-engineer` |
| Monitoring / Observabilidade | `arch--monitoring-expert` |
| Refatorar código ruim | `dev--code-refactoring` |
| Simplificação pontual | `code-simplifier` (agente) |
| Economizar tokens na conversa | `tools--caveman` |
| Delegar com output comprimido | `tools--cavecrew` |
| Commit message curta | `tools--caveman-commit` |
| Review curto e acionável | `tools--caveman-review` |
| Comprimir arquivo de memória | `tools--caveman-compress` |
| Ajuda dos comandos Caveman | `tools--caveman-help` |
| Ver uso real de tokens | `tools--caveman-stats` |
| Planejar roadmap do projeto | `product--project-planner` |
| Validar antes de construir | `product--product-discovery` |
| Qualquer coisa com N8N | `n8n--using-skills` (roteia automaticamente) |
| Novo workflow N8N | `n8n--workflow-lifecycle` → `n8n--node-configuration` |
| Expressão N8N com erro | `n8n--expressions` |
| Agente IA no N8N | `n8n--agents` |
| Loop / batch N8N | `n8n--loops` |
| Erro em workflow N8N | `n8n--debugging` → `n8n--error-handling` |
| Credenciais / OAuth N8N | `n8n--credentials-and-security` |
| Código JS/Python no N8N | `n8n--code-nodes` |
| Subworkflow / reuso N8N | `n8n--subworkflows` |
