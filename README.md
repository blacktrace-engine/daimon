# Daimon

> **A persistent synthetic mind.**
>
> Not a model.
> Not an agent.
> Not a swarm.
>
> A **daimon** is an entity that continuously exercises cognition against reality.

---

## The problem

Models are not minds.

A model can infer.
It can reason.
It can remember what is placed in its context.

Then the process ends.

The context disappears.
The worker dies.
The next invocation begins again.

We call this an agent.

Then we add more agents.

But multiplying ephemeral inference does not create persistent intelligence.

**A swarm of processes is not a mind.**

Daimon starts from a different premise:

> **The intelligence is already in the model.**
> **The missing primitive is the entity that can continuously exercise it.**

---

## What is a Daimon?

A **daimon** is a persistent synthetic intelligence composed of:

- cognition
- memory
- continuity
- intent
- bounded agency
- environmental feedback
- outcome awareness

Its agency is not unlimited.

A daimon cannot do what its world does not allow it to do.

It may intend to buy an aircraft.

That does not mean an aircraft appears.

It must possess the means, interfaces, resources and circumstances necessary for the action.

**Agency emerges from capability × affordance × state.**

The daimon does not get to declare reality.

Reality gets to answer.

---

## The invariant

A daimon may not claim that something happened

unless the runtime can establish that it happened.

It may not claim to have:

- monitored something it could not observe
- remembered something it did not persist
- completed something it did not verify
- acted where no action occurred
- learned where no durable state changed
- continued where its state was lost

**Inference is not evidence.**

**Intention is not execution.**

**Execution is not outcome.**

**Claim is not reality.**

---

## The loop

```text
        ┌──────────────────────────────────────────┐
        │                                          │
        ▼                                          │
     EVENT                                          │
        │                                            │
        ▼                                            │
   RETRIEVE STATE                                    │
        │                                            │
        ▼                                            │
   SELECT CONTEXT                                    │
        │                                            │
        ▼                                            │
      INFER                                          │
        │                                            │
        ▼                                            │
    AUTHORIZE                                        │
        │                                            │
        ▼                                            │
      ACT                                            │
        │                                            │
        ▼                                            │
     VERIFY ──────────────── reality                 │
        │                                            │
        ▼                                            │
     MEASURE                                         │
        │                                            │
        ▼                                            │
    PERSIST                                          │
        │                                            │
        ▼                                            │
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
context reconstructs
      ↓
cognition resumes
      ↓
affordances are evaluated
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

The distinction is continuity.

```text
MODEL
  │
  │ inference
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

They are processes through which the daimon exercises its cognition.

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

The runtime turns that outcome into explicit conditions.

Those conditions constrain what may be considered progress.

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

---

## The first primitive

We have spent decades making machines execute instructions.

We are now making machines generate intelligence.

The next primitive is not another model.

It is the **entity that persists while intelligence is being exercised**.

> **Model → process → agent → daimon**

Not a hierarchy of intelligence.

A progression of **entityhood**.

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

> **If the daimon cannot prove that reality changed, the daimon must behave as though it did not.**

Everything else follows from this.
