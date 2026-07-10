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
- [Skills Oficiais Anthropic (Superpowers)](#skills-oficiais-anthropic-superpowers)
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
~/.claude/skills/          → suas 33 skills globais (qualquer projeto)
~/.claude/plugins/cache/   → skills oficiais Anthropic (Superpowers, frontend-design, etc.)
<projeto>/.claude/skills/  → skills específicas de cada projeto
```

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

### `graphify`
**O que é:** Transforma qualquer pasta de arquivos em grafo de conhecimento navegável com detecção de comunidades, auditoria de mudanças e três saídas: HTML interativo, JSON pronto para GraphRAG e relatório legível em Markdown.

**Propósito central:** Responder perguntas sobre a arquitetura e relacionamentos de arquivos de um codebase — especialmente quando `graphify-out/` existe, questões devem ser tratadas como queries do graphify primeiro.

**Responsabilidades:**
- Gerar grafo de conhecimento persistente do codebase (`graphify-out/graph.json`)
- Criar visualização interativa HTML com comunidades detectadas
- Fornecer três ferramentas de query para exploração:
  - `graphify query "<pergunta>"` — retorna subgrafo relevante
  - `graphify path "<A>" "<B>"` — mostra relacionamentos entre conceitos
  - `graphify explain "<conceito>"` — explica conceitos focados
- Gerar `GRAPH_REPORT.md` com análise de arquitetura
- Manter grafo atualizado com `graphify update .` (incremental, AST-only)
- Suportar entrada múltipla (arquivos locais, GitHub repos, papers + código)

**Quando usar:**
1. **Entender arquitetura de um codebase** — use query/path/explain para navegação rápida
2. **Responder perguntas técnicas sobre o projeto** — codebase questions → graphify query ANTES de grep/read bruto
3. **Analisar relacionamentos entre módulos** — entender acoplamentos, dependências cruzadas, comunidades
4. **Onboarding em repositório novo** — construir grafo, ler `GRAPH_REPORT.md`, depois codebase é navegável
5. **Arquivos modificados recentemente** — `graphify update .` mantém o grafo sincronizado com mudanças de código

**Como usar:**
```bash
# Pipeline completo (gera HTML + JSON + GRAPH_REPORT.md)
graphify                                           # codebase atual
graphify <caminho>                                 # pasta específica
graphify https://github.com/<owner>/<repo>        # clonar repo e processar
graphify <repo1> <repo2> ...                       # múltiplos repos com merge

# Modos e opções
graphify <caminho> --mode deep                    # extração richer com mais inferências
graphify <caminho> --update                       # incremental - só novos/alterados
graphify <caminho> --directed                     # grafo direcionado (preserva A→B)
graphify <caminho> --cluster-only                 # reclusterizar grafo existente
graphify <caminho> --no-viz                       # JSON + report, pula visualização
```

**Outputs:**
- `graphify-out/` → diretório com todos os resultados
- `graphify-out/index.html` → visualização interativa (abrir no browser)
- `graphify-out/graph.json` → JSON para uso programático ou GraphRAG
- `graphify-out/GRAPH_REPORT.md` → análise legível de arquitetura
- `graphify-out/wiki/` → índice de navegação (se `--obsidian` usado)

**Regras ao usar:**
1. Se `graphify-out/graph.json` existe, sempre use `query/path/explain` para codebase questions ANTES de grep/read
2. Se `graphify-out/wiki/index.md` existe, use para navegação ampla ao invés de browsar fonte bruto
3. Após modificações de código, rodar `graphify update .` mantém o grafo consistente (AST-only, sem custo de API)
4. Use `GRAPH_REPORT.md` para análise arquitetural ampla quando query/path/explain insuficientes

**Sinergia com:** `learn--project-mentor` (understand project structure) + `learn--spec-miner` (reverse-engineer code) + `dev--code-reviewer` (entender impacto arquitetural de mudanças)

---

## n8n-- → Automação N8N

> Skills oficiais do n8n — fonte: [`n8n-io/skills`](https://github.com/n8n-io/skills)
> Cobrem o ciclo completo de automação: design, configuração de nós, expressões, loops, agentes IA, erros, credenciais, debugging e deploy.
> **Regra central:** invocar a skill correspondente **antes** de qualquer ação no n8n — o MCP do n8n evolui mais rápido do que o training cutoff de qualquer modelo.

### `n8n--using-skills` Meta-skill roteadora
**O que é:** Protocolo sempre ativo — carregado em toda sessão. Roteia para a skill correta, resume todas as ferramentas MCP do n8n e estabelece as regras transversais.

**Regras não-negociáveis:**
1. Invocar a skill relevante **antes** de qualquer ação n8n — não apenas chamadas MCP
2. `validate_workflow` antes de publicar + `get_workflow_details` após criar/atualizar para verificar as `connections`
3. Tokens e secrets **nunca** em campos de texto — sempre usar o sistema de credenciais do n8n

---

### `n8n--workflow-lifecycle`
**O que é:** Design, organização e publicação de workflows — do início ao deploy.

**Responsabilidades:** layout visual (sticky notes), nomes de nós, validação, testes, pastas/projetos, publicação.

---

### `n8n--node-configuration`
**O que é:** Configuração correta de qualquer nó n8n — HTTP, webhooks, banco, Slack/Gmail, AI, triggers, Merge.

**Responsabilidades:** parâmetros de nós, `useDataOfInput`, `numberOfInputs`, fan-in, debugging de nó específico.

---

### `n8n--expressions`
**O que é:** Escrita e revisão de expressões n8n (`{{...}}`), referências `$json`/`$node`, datas com Luxon.

**Responsabilidades:** sintaxe de expressões, `$input`, `$node`, `DateTime`, formatação de datas, erros de expressão.

---

### `n8n--subworkflows`
**O que é:** Modularização — quando extrair lógica repetível em subworkflows.

**Responsabilidades:** reuso de lógica, workflows com +10 nós, lógica compartilhada entre projetos.

---

### `n8n--loops`
**O que é:** Processamento de múltiplos itens — batches, APIs paginadas, rate limits, paralelismo.

**Responsabilidades:** loop/iterate, "for each", batching, paginação, fan-out, concorrência, nó executado uma vez vs. uma vez por item.

---

### `n8n--error-handling`
**O que é:** Tratamento de erros em workflows de produção — webhooks, agendados, saídas de erro por nó.

**Responsabilidades:** `onError`, `continueErrorOutput`, error workflows, try/catch, branches de erro, workflows não supervisionados.

---

### `n8n--agents`
**O que é:** Construção de features de IA no n8n — AI Agents, LLM chains, vector stores, embeddings, classificadores, extratores.

**Responsabilidades:** nodes `@n8n/n8n-nodes-langchain.*`, tool calling, `fromAi`, system prompts, memória, structured output, RAG, geração de mídia com IA.

---

### `n8n--credentials-and-security`
**O que é:** Autenticação e segurança — API keys, OAuth, tokens, credenciais de terceiros.

**Responsabilidades:** `Authorization header`, `x-api-key`, bearer tokens, OAuth, secrets — nunca em campos de texto.

---

### `n8n--code-nodes`
**O que é:** Nós de código JavaScript/Python no n8n — lógica customizada que não cabe em nós nativos.

**Responsabilidades:** Code node, transformações com `$input`/`$json`, quando usar (e quando **não** usar) código.

---

### `n8n--data-tables`
**O que é:** Data Tables do n8n — schemas, inserção/upsert, deduplicação, estado persistente entre execuções.

**Responsabilidades:** `n8n-nodes-base.dataTable`, idempotência, lookup, dedup, armazenamento cross-execução.

---

### `n8n--binary-and-data`
**O que é:** Arquivos, imagens, PDFs e dados binários em workflows n8n.

**Responsabilidades:** upload/download de arquivos, chat trigger com arquivos, agente recebendo/retornando arquivo, visão/multimodal.

---

### `n8n--debugging`
**O que é:** Investigação de workflows com erro, output inesperado ou comportamento incorreto.

**Responsabilidades:** erros de execução, "it's not working", output divergente, workflow parado, investigação de falha.

---

### `n8n--extending-mcp`
**O que é:** Expor workflows n8n como ferramentas MCP chamáveis pelo agente.

**Responsabilidades:** wrapping de capacidades não nativas do MCP (folder/tag CRUD, metadata), expor workflows como tools para o agente.

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
graphify                   → gera grafo persistente + visualização
graphify query/path/explain → navega o grafo para perguntas rápidas
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
| TypeScript complexo | `frontend--typescript-pro` |
| Python moderno | `dev--python-pro` |
| Query lenta | `db--database-optimizer` + `db--sql-pro` |
| Criar agentes | `ai--agent-development` + `ai--prompt-engineer` |
| Criar agente com Agno (único) | `ai--agno` → `ai--prompt-engineer` + `ai--agent-development` |
| Criar time de agentes | `ai--multi-agent-architect` → `ai--agent-development`/`ai--agno` → `ai--prompt-engineer` |
| Entender lib externa | `learn--project-mentor` |
| Entender trecho de código | `learn--code-teacher` |
| Código sem documentação | `learn--spec-miner` |
| Pergunta sobre codebase | `graphify` (query/path/explain) |
| Explorar arquitetura do projeto | `graphify query` (se graphify-out/ existir) |
| Onboarding em novo repo | `graphify` → ler GRAPH_REPORT.md → `learn--project-mentor` |
| Escrever testes | `test-driven-development` + `dev--test-master` |
| Pronto para commitar | `verification-before-completion` (automático) |
| Criar PR | `requesting-code-review` → `finishing-a-development-branch` |
| Recebeu feedback de review | `receiving-code-review` |
| Dados → relatório | `data--pandas-pro` → `data--storyteller` |
| Deploy / Docker | `arch--devops-engineer` |
| Monitoring / Observabilidade | `arch--monitoring-expert` |
| Refatorar código ruim | `dev--code-refactoring` |
| Simplificação pontual | `code-simplifier` (agente) |
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
