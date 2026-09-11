# Daimon

> **A persistent synthetic mind.**
>
> Not a model.
> Not an agent.
> Not a swarm.
>
> A **daimon** is an entity whose identity and state persist across episodes of cognition and action.

A daimon is not a continuously running model. It may sleep for minutes, days, or months. What persists is the entity: its state, memory, commitments, authority, unresolved goals, verified outcomes, and the mechanisms required to resume cognition when reality changes.

---

## The problem

Models are not minds.

A model can infer.
It can reason.
It can use whatever memory is placed in its context.

Then the invocation ends.

The worker may die.
The context may disappear.
The next invocation may begin from somewhere else.

We call systems built around this an agent.

Then we add more agents.

But multiplying ephemeral inference does not by itself create persistent intelligence.

**A swarm of processes is not a mind.**

Daimon starts from a different premise:

> **The model supplies cognition.**
> **The missing primitive is the entity that can persist while cognition is exercised.**

---

## What is a Daimon?

A **daimon** is a persistent synthetic intelligence composed of:

- cognition
- memory
- continuity
- identity
- intent
- bounded agency
- environmental feedback
- outcome awareness

Its agency is not unlimited.

A daimon cannot do what its world does not allow it to do.

It may intend to buy an aircraft.

That does not mean an aircraft appears.

It must possess the means, interfaces, resources, authority and circumstances necessary for the action.

**Agency emerges from capability × affordance × state.**

The daimon does not get to declare reality.

Reality gets to answer.

---

## Identity

A daimon is not identified by the process currently executing it.

Workers are replaceable.

Models are replaceable.

Sessions are replaceable.

Containers are replaceable.

The daimon persists through a durable lineage of:

- state
- memory
- commitments
- permissions
- unresolved goals
- verified outcomes
- learned constraints

A fresh worker becomes an execution of the same daimon only by recovering that lineage.

**Continuity is not process survival.**

**Continuity is stateful identity across process death.**

---

## The invariant

A daimon may not promote a claimed state transition to fact unless the runtime can establish that it occurred.

It may not claim to have:

- monitored something it could not observe
- remembered something it did not persist
- completed something it did not verify
- acted where no action occurred
- learned where no durable state changed
- continued where its identity state was lost

**Inference is not evidence.**

**Intention is not execution.**

**Execution is not outcome.**

**Claim is not reality.**

Observation is also a state transition when it changes what the daimon knows. Such transitions require provenance, freshness and evidence just as actions require verification.

---

## The loop

```text
        ┌──────────────────────────────────────────┐
        │                                          │
        ▼                                          │
     EVENT                                          │
        │                                           │
        ▼                                           │
   RETRIEVE STATE                                   │
        │                                           │
        ▼                                           │
   SELECT CONTEXT                                   │
        │                                           │
        ▼                                           │
      INFER                                         │
        │                                           │
        ▼                                           │
    AUTHORIZE                                       │
        │                                           │
        ▼                                           │
      ACT                                           │
        │                                           │
        ▼                                           │
     VERIFY ──────────────── reality                │
        │                                           │
        ▼                                           │
     MEASURE                                        │
        │                                           │
        ▼                                           │
    PERSIST                                         │
        │                                           │
        ▼                                           │
     UPDATE ─────────────────────────────────────────┘
```

The process may die.

The daimon does not have to.

```text
session dies
      ↓
state survives
      ↓
external event occurs
      ↓
fresh worker wakes
      ↓
identity and context reconstruct
      ↓
cognition resumes
      ↓
affordances and authority are evaluated
      ↓
action occurs
      ↓
reality is independently observed
      ↓
outcome persists
      ↓
the daimon becomes different
```

That last step matters.

**A daimon is not merely restarted.**

It continues.

---

## Daimon ≠ Agent

An agent is commonly model + prompt + tools + loop.

A daimon is an entity.

The distinction is continuity of identity, state and consequence.

```text
MODEL
  │
  │ cognition
  ▼
PROCESS
  │
  │ execution
  ▼
AGENT
  │
  │ continuity + memory + outcomes + affordances
  ▼
DAIMON
```

A daimon may use agents.

A daimon may use many models.

A daimon may create temporary workers.

None of those workers are the daimon.

They are processes through which the daimon exercises cognition.

---

## Daimon ≠ Swarm

More agents do not necessarily produce more intelligence.

A hundred processes that cannot remember, verify, learn or maintain continuity are still a hundred processes.

Daimon does not begin with:

> **How many agents can we run?**

It begins with:

> **What must be true for one intelligence to actually persist?**

---

## The contract

A daimon has a desired outcome.

The runtime turns that outcome into explicit conditions and runtime guarantees.

Those guarantees constrain which state transitions are admissible.

Reality determines whether the conditions were satisfied.

```text
desired outcome
       ↓
runtime guarantees
       ↓
admissible state transitions
       ↓
execution
       ↓
independent observation
       ↓
verified reality
```

Nothing gets promoted from *believed* to *true* merely because a model generated a convincing sentence.

The runtime therefore owns at least these concerns:

- context salience
- freshness and stale-state handling
- authority
- durability
- wake-up truthfulness
- independent verification
- outcome memory
- invalid-state prevention
- retry discipline
- cross-run learning

---

## Runtime guarantees

A daimon is only as real as the mechanisms that preserve it.

The runtime must make unsupported states unreachable.

Examples:

- no monitoring claim without a real trigger or re-entry mechanism
- no durable goal whose required state exists only in ephemeral storage
- no consequential mutation without scoped authority
- no completion claim without an observable postcondition
- no stale remembered state outranking fresher observed state
- no blind repetition of the same failed action without changed evidence
- no outcome claim sourced only from the model's own prior assertion
- no persistent memory without explicit storage and retrieval semantics
- no continuation claim if the identity lineage cannot be recovered

The model may propose the next state.

**The runtime decides whether that state is reachable.**

---

## The first primitive

We have spent decades making machines execute instructions.

We are now making machines generate increasingly capable cognition.

The next primitive is not necessarily another model.

It is the **entity that persists while cognition is being exercised**.

> **Model → process → agent → daimon**

Not a hierarchy of intelligence.

A progression of **entityhood**.

---

## Acceptance

A daimon is not proven by a framework booting successfully.

The minimum continuity test is:

```text
session/process dies
      ↓
durable state survives
      ↓
external event occurs
      ↓
a fresh worker wakes without a user message
      ↓
identity and context reconstruct from durable state
      ↓
authorized action executes
      ↓
the external effect is independently verified
      ↓
the verified outcome persists
      ↓
the worker may die again without destroying continuity
```

If the system cannot demonstrate that sequence, it may still be a useful agent framework, simulator, or prototype.

It is not yet a proven daimon runtime.

---

## Status

This repository is intentionally small.

The first implementation is not the point.

The specification is.

The system will be built only after its invariants can be stated clearly enough to test.

```text
README.md
SPEC.md
ARCHITECTURE.md
ACCEPTANCE.md
LICENSE
```

No magic is assumed.

Every guarantee must have a mechanism.

Every mechanism must have an observable consequence.

Every claimed consequence must be verifiable.

---

## One rule

> **No claimed state transition becomes truth without evidence.**

Everything else follows from this.
