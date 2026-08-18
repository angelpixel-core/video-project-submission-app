---
id: PROMPT
aliases: []
tags: []
---

# Task: Generate the Root `README.md`

Create or completely rewrite the root `README.md` for this project.

The README must be a **professional, portfolio-quality technical README** that accurately explains what the application does, how it is designed, how to run it, and how it is deployed.

Do not write the README based only on the current directory structure or on this prompt.

Before writing anything, inspect the repository thoroughly and reconstruct the actual current state of the project.

---

## 1. Repository Discovery

Start by exploring the repository from the root.

Inspect, where available:

- Existing `README.md`
- Application source code
- Routes
- Models / entities
- Controllers / endpoints
- Views / frontend code
- Services
- Commands / queries / use cases
- Domain modules
- Adapters
- Providers
- Background jobs
- Database schema and migrations
- Seeds / fixtures
- Tests
- Configuration
- Environment variables
- `Gemfile`
- package manifests
- Docker-related files
- `Makefile`
- Rake tasks
- CI/CD configuration
- `ops/`
- Terraform files
- Render configuration
- scripts
- architecture documentation
- ADRs / decisions
- work items
- changes
- sprint documentation
- planning documents
- implementation notes
- any other project-management or engineering documentation stored inside the repository.

Use repository search aggressively rather than assuming where information lives.

The objective is to understand both:

1. **what the system currently does**, and
2. **why important architectural decisions were made**.

---

## 2. Establish the Source of Truth

Documentation may contain historical plans, abandoned ideas, completed work items, experiments, or architecture that changed later.

Use this precedence when resolving conflicts:

1. Current working implementation
2. Current configuration / infrastructure
3. Tests
4. Recent architectural decisions / ADRs
5. Recent changes and completed work items
6. Older work items, sprint documents, and planning documents
7. Existing README

Do not describe planned functionality as implemented functionality.

If something appears in documentation but cannot be verified in the current implementation, either:

- omit it, or
- explicitly describe it as planned / experimental / incomplete when it is important enough to mention.

Do not invent commands, environment variables, dependencies, architecture, deployment steps, URLs, credentials, or features.

---

# 3. Understand the Product

The application is centered around purchasing and managing a service, currently modeled around **video editing / video production orders**.

Verify the exact terminology used by the implementation.

At a high level, investigate and document the relevant workflows.

### Customer workflow

Determine how a customer can:

- create or submit an order/request;
- specify the requested service;
- inspect their order;
- see its current state;
- interact with the payment flow;
- see payment/order status;
- perform any other customer operations currently implemented.

### Manager workflow

Determine how a manager can:

- inspect submitted orders;
- review order details;
- manage or transition order states;
- inspect payment information;
- verify/check payments;
- perform operational actions related to fulfillment;
- perform any other management operations currently implemented.

Do not assume these capabilities exist exactly as described above. Verify them against the implementation.

Explain the distinction between the **customer-facing workflow** and the **management/operations workflow** clearly.

---

# 4. Payments

Payments are an important architectural area of the project.

Inspect the payment domain and document what actually exists.

Look for concepts such as:

- payment intents;
- payment providers;
- provider adapters;
- fake/test providers;
- payment simulation;
- payment verification;
- payment status transitions;
- callbacks/webhooks;
- idempotency;
- retries;
- persistence of provider requests/responses;
- external provider integrations;
- customer payment operations;
- manager payment verification.

If the project intentionally separates domain/payment logic from external payment providers, explain that architecture.

Do not imply that a real payment provider is production-ready unless the implementation confirms it.

---

# 5. Architecture

Inspect the repository and determine the architecture actually being used.

The project has intentionally explored concepts such as:

- Domain-Driven Design
- bounded/domain modules
- hexagonal architecture
- ports and adapters
- commands / queries / use cases
- domain events
- background processing
- provider abstractions
- infrastructure isolation

Only include concepts that are actually represented in the codebase.

Create a concise **Architecture** section explaining:

- major modules/domains;
- important boundaries;
- dependency direction;
- how external providers are isolated;
- how application/domain/infrastructure concerns are separated;
- how the design supports future extension.

Avoid turning the README into an architecture textbook.

The explanation should help another senior engineer understand the repository quickly.

If a diagram would materially improve this section, insert a placeholder such as:

```md
<!-- TODO: Add architecture diagram -->
<!-- Suggested capture/diagram: high-level domains + adapters + infrastructure -->
```

Do not generate fake diagrams unless the repository already contains one that can be referenced.

---

# 6. Repository Structure

Add a concise directory tree showing only architecturally meaningful directories.

For example:

```text
.
├── app/
├── ...
├── ops/
├── ...
└── ...
```

Do not dump the entire repository tree.

After the tree, briefly explain the responsibility of important directories whose purpose would not be obvious to a new contributor.

---

# 7. Operations and Infrastructure

The `ops/` directory is an important part of this project.

Inspect it carefully.

Explain its purpose and structure.

The project aims to keep operational and deployment concerns organized under this area and supports Infrastructure as Code.

Specifically investigate and document:

- Terraform
- Render
- environment configuration
- deployment scripts
- infrastructure modules
- operational commands
- bootstrap/setup processes
- CI/CD integration, if present
- database provisioning
- secrets/environment handling
- any one-shot deployment/bootstrap workflow

The intended direction is for deployment/setup to become as close as practical to a **one-shot operation**, but do not claim this is fully achieved unless the current implementation supports it.

When appropriate, distinguish between:

- what works today;
- what is automated;
- what still requires manual configuration.

---

# 8. Terraform + Render

The project includes Infrastructure as Code intended to deploy infrastructure/application resources using **Terraform** and **Render**.

Verify the exact implementation.

Document:

- Terraform prerequisites;
- relevant providers;
- required variables;
- initialization;
- planning;
- applying;
- outputs;
- Render-specific configuration;
- required manual steps, if any.

Use only commands verified from the repository.

Do not invent Terraform commands beyond standard commands unless they match the project's actual workflow.

If the repository provides wrappers such as:

```bash
make ...
bin/...
rake ...
```

prefer the project's documented abstraction over raw lower-level commands.

---

# 9. Local Development

Produce accurate setup instructions for a developer cloning the repository for the first time.

Determine the actual prerequisites.

Examples may include:

- Ruby version
- Rails version
- Node.js
- package manager
- database
- Redis
- Faktory or another job system
- Terraform
- Render CLI
- Docker
- Make

Only list dependencies actually required by the repository.

Provide a clear sequence for:

1. cloning;
2. installing dependencies;
3. configuring environment variables;
4. preparing the database;
5. running required infrastructure/services;
6. starting the application;
7. accessing the application.

Prefer existing project commands (`make`, `bin/setup`, `bin/dev`, Rake tasks, etc.) where available.

---

# 10. Environment Variables

Inspect the repository for required environment variables.

Create an Environment / Configuration section.

Never expose actual secrets.

Use names only, for example:

```env
DATABASE_URL=
PAYMENT_PROVIDER_API_KEY=
...
```

Separate them when useful into:

- required;
- optional;
- development/test;
- deployment/infrastructure.

If `.env.example` exists, reference it rather than duplicating unnecessary information.

---

# 11. Testing and Quality

Inspect the actual test/tooling configuration.

Document how to run relevant checks such as:

- unit tests;
- integration tests;
- system tests;
- linters;
- formatters;
- security checks;
- architecture checks;
- CI-equivalent checks.

Prefer a single canonical command if the repository provides one.

For example, if something like:

```bash
make test
make check
bin/ci
```

already orchestrates multiple checks, explain that rather than making contributors execute every tool manually.

---

# 12. Screenshots / Visual Documentation

Add image placeholders where visual evidence would make the README stronger.

Do not invent image paths or screenshots that do not exist.

Use TODO comments such as:

```md
<!-- TODO: Add screenshot: customer order creation flow -->
```

Potentially useful screenshots include, if those screens exist:

### Main application

```md
<!-- TODO: Add screenshot: application overview / dashboard -->
```

### Customer order

```md
<!-- TODO: Add screenshot: customer viewing an order and its current status -->
```

### Payment flow

```md
<!-- TODO: Add screenshot: customer payment workflow -->
```

### Manager operations

```md
<!-- TODO: Add screenshot: manager order management / payment verification -->
```

Do not add placeholders merely for decoration. Use them where they help explain an important capability.

---

# 13. README Structure

Use the following structure as a strong default, but adapt it if the repository suggests a better organization.

```md
# Project Name

Short positioning statement.

[badges, only if they can be generated accurately]

<!-- hero/application screenshot placeholder -->

## Overview

## Features

## Product Workflows

### Customer Workflow

### Manager Workflow

### Payment Workflow

## Architecture

### Domains / Modules

### Ports and Adapters

### External Integrations

## Project Structure

## Tech Stack

## Getting Started

### Prerequisites

### Installation

### Configuration

### Database Setup

### Running the Application

## Testing

## Operations

### Ops Structure

### Infrastructure as Code

### Terraform

### Render Deployment

## Development Workflow

## Current Limitations / Project Status

## Roadmap

(optional — only if supported by repository documentation)

## License
```

Do not force empty sections.

Remove or reorganize sections when they do not improve the README.

---

# 14. Writing Style

Write the README in **English**.

Target the document at:

- senior software engineers;
- technical recruiters;
- engineering managers;
- potential collaborators;
- someone evaluating the repository as part of a portfolio.

The writing should be:

- concise;
- technical;
- professional;
- factual;
- confident without exaggeration;
- easy to scan.

Prefer explaining engineering intent over merely enumerating technologies.

For example, avoid:

> This project uses Terraform.

Prefer:

> Deployment infrastructure is defined with Terraform under `ops/`, keeping application code and operational concerns independently manageable.

Likewise, avoid presenting every implementation detail as a "feature".

Highlight the engineering decisions that demonstrate:

- product thinking;
- backend architecture;
- integration design;
- payment workflows;
- operational ownership;
- infrastructure automation;
- maintainability;
- extensibility.

---

# 15. Important Constraints

Do **not**:

- invent functionality;
- invent deployment URLs;
- invent credentials;
- expose secrets;
- claim unfinished work is complete;
- describe obsolete architecture as current;
- copy internal work-item documentation into the README;
- make the README excessively long;
- add meaningless badges;
- add generic marketing language;
- create sections simply because typical GitHub READMEs contain them.

Internal documentation should be **synthesized**, not copied.

The README should describe the project's **current coherent story**, not its entire development history.

---

# 16. Final Verification

Before modifying `README.md`, verify every important statement against the repository.

Specifically verify:

- project name;
- framework/runtime versions;
- database;
- background processing;
- frontend technology;
- domains/modules;
- payment capabilities;
- available providers;
- customer capabilities;
- manager capabilities;
- test commands;
- development commands;
- Terraform structure;
- Render integration;
- deployment commands;
- environment variables.

Then write the final root `README.md`.

After writing it, review the README once more against the repository and remove or correct any unsupported claims.

---

# Expected Result

The final README should allow someone unfamiliar with the project to understand, within a few minutes:

1. **What product is this?**
2. **What problem does it solve?**
3. **What can the customer do?**
4. **What can the manager/operator do?**
5. **How does the payment flow work?**
6. **How is the application architected?**
7. **How do I run it locally?**
8. **How do I run the tests?**
9. **How is it deployed?**
10. **What role do `ops/`, Terraform, and Render play?**
11. **What is implemented today versus still evolving?**

The result should feel like the README of a serious production-oriented engineering project rather than a tutorial project.

Proceed autonomously: inspect the repository, resolve inconsistencies using the source-of-truth rules above, and then create/update the root `README.md`.
