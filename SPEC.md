# Daimon Specification

Daimon is a runtime contract for persistent synthetic identity across disposable cognition workers.

## Core definition

A Daimon is not a continuously running model. It is a durable identity whose state, commitments, authority, verified outcomes, and unresolved goals survive between episodes of cognition.

The model supplies cognition. Workers supply execution. The runtime supplies continuity.

## Core loop

```text
event
  ↓
retrieve durable state
  ↓
select relevant context
  ↓
infer
  ↓
authorize
  ↓
act
  ↓
verify against reality
  ↓
measure outcome
  ↓
persist verified state
  ↓
update future context
```

## Required runtime properties

A conforming Daimon runtime owns, directly or through explicit adapters:

1. **Identity** — a stable identity independent of any model, worker, container, or session.
2. **Durability** — state required for continuity survives worker/session death.
3. **Wake/re-entry** — external events can cause fresh compute to resume the identity without requiring a human message.
4. **Context reconstruction** — fresh workers recover the minimum relevant durable state before inference.
5. **Freshness** — observed current state outranks stale remembered state.
6. **Authority** — consequential actions are constrained by explicit scope.
7. **Verification** — tool success and model assertions do not establish outcome truth.
8. **Outcome memory** — verified outcomes alter durable future state.
9. **Invalid-state prevention** — the runtime may reject model-proposed transitions that are unsupported or unreachable.
10. **Retry discipline** — unchanged failed actions are not repeated without changed evidence or state.

## Truth classes

Runtime state should distinguish at least:

- proposed
- observed
- authorized
- executed
- verified
- refuted
- unknown

A model-generated assertion does not itself move a fact into `verified`.

## Invariants

- No monitoring claim without a real re-entry mechanism.
- No persistent memory claim without durable storage and retrieval semantics.
- No completion claim without an observable postcondition.
- No consequential mutation outside granted authority.
- No stale remembered state outranks fresher observed state.
- No failed action repeats unchanged without new evidence or state.
- No verified outcome may be sourced only from the acting model's own assertion.
- No continuity claim if identity state cannot be recovered after the worker dies.

## Identity lineage

A fresh worker is an execution of the same Daimon only when it recovers the identity lineage required to constrain future cognition and action.

Minimum lineage:

```text
identity
state version / generation
unresolved goals
permissions / authority
verified outcomes
relevant durable memory
learned constraints
```

The worker is replaceable. The lineage is not.

## Non-goals

Daimon does not require:

- one specific model
- continuous inference
- a swarm
- one vendor
- one database
- one scheduler
- unlimited agency

Implementations may vary. The invariants do not.

## Prime rule

> No claimed state transition becomes truth without evidence.
