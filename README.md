

# Verification of Concurrent Systems
### SERI 2026 | IISc Bangalore

---

## Overview

This project explores the verification of concurrent systems, focusing on model checking, temporal logic specifications, unbounded communication channels, and abstraction-based static analysis.

The work was presented at **SERI 2026** and is based on research conducted during the ACM iSoft ASCENT internship at IISc Bangalore.

The primary objective is to understand how concurrent systems can be analyzed for correctness while balancing analysis precision, state-space exploration, and computational efficiency.

## Topics Covered

- Model checking using SPIN
- Concurrent client-server systems modeled in Promela
- Safety and liveness verification using Linear Temporal Logic (LTL)
- Global state automata and execution-trace analysis
- Vector Addition Systems (VAS)
- Karp–Miller tree construction and acceleration
- Lattice-based reachability analysis
- Assertion analysis and abstract interpretation
- Widening, precision preservation, and state-space pruning

---

## 1. Model Checking with SPIN

SPIN is a model checker used to analyze concurrent systems and verify behavioral properties.

Promela (Process Meta Language) describes concurrent processes, communication channels, and system behavior.

### Client–Server Model

The model consists of two clients communicating with a central server through request, grant, and return channels.

**Key assumptions:**

- **Single request bound:** Each client has at most one active request at a time.
- **Nondeterministic selection:** The server chooses among pending requests nondeterministically.
- **Release cycle:** After completing its critical section, a client sends a return message to the server.



### Simplified Promela Model

```promela
active proctype Client(byte id)
{
    do
    :: req_ch ! id;
       grant_ch ? eval(id);

       in_cs[id] = true;

       /* Critical section */

       in_cs[id] = false;
       ret_ch ! id;
    od
}

active proctype Server()
{
    do
    :: if
       :: req_ch ? 0 ->
          grant_ch ! 0;
          ret_ch ? eval(0);

       :: req_ch ? 1 ->
          grant_ch ! 1;
          ret_ch ? eval(1);
       fi
    od
}
```

*Note: This is a simplified illustration of the model presented in the slides, not a complete standalone SPIN input file.*

---

## 2. Safety and Liveness Verification

Concurrent systems must satisfy both safety and liveness properties.

### Safety: Mutual Exclusion

Mutual exclusion ensures that both clients cannot occupy their critical sections simultaneously.

```promela
ltl safe {
    [] !(in_cs[0] && in_cs[1])
}
```

**Result reported in the presentation:** Passed.

### Liveness: Request–Grant Progress

The request–grant property expresses that a request from client 1 should eventually receive a corresponding grant.

```promela
ltl req_grant {
    [] (req_ch ? [1] -> <> grant_ch ? [1])
}
```

**Result reported in the presentation:** Failed.

This motivates further investigation into progress guarantees and starvation in nondeterministic concurrent systems.

---

## 3. Global State Automaton and Trace Analysis

The global state automaton illustrates how different execution paths affect progress.



- **Passing progress trace:** Requests from both clients are eventually granted.
- **Failing starvation trace:** The server repeatedly grants client 0 while client 1 remains pending.

This illustrates why mutual exclusion alone is insufficient: a system can satisfy safety while failing to guarantee progress.

---

## 4. Transition to Abstraction

SPIN's explicit-state approach tracks concrete states and communication-channel contents.

When communication channels become unbounded, the number of possible configurations can grow without bound, making exhaustive exploration infeasible.

### Vector Addition Systems

Vector Addition Systems (VAS) represent communication events using numeric token counters. This provides an abstraction for reasoning about unbounded communication behavior.

### Karp–Miller Algorithm

The classical Karp–Miller algorithm constructs a tree representing reachable states of an unbounded system.


**Acceleration rule**

When a newly reached state covers an ancestor state with the same control configuration, strictly increasing counters can be accelerated to abstract infinity, denoted by `ω`.

**Subsumption rule**

A newly generated state can be pruned when an existing state with the same control configuration covers it. This avoids redundant exploration and supports termination of the tree construction.

---

## 5. Advanced Research Framework

The laboratory had developed a unified static-analysis approach designed to analyze concurrent behavior by considering communication states and internal program-variable values together.

### Joint Verification Architecture

The framework simultaneously considers:

- Message-queue configurations
- Internal program-variable values
- Global control invariants
- Abstract-domain structures

### Lattice-Based Reachability

Lattice-based reachability analysis tracks abstract variable values across product states of concurrent processes.

This allows the analysis to reason about program assertions while accounting for different interleavings of concurrent execution.


---

## 6. Assertion Analysis and Widening

A central challenge in abstract interpretation is balancing termination with sufficient precision.

Widening helps ensure convergence during iterative analysis, but premature widening can introduce imprecision and false-positive assertion failures.

### Case A: Diverging Process Automata

The first example considers concurrent operations that increment and decrement a shared abstract counter.

The assertion is:

```c
assert(count <= 2);
```

At the assertion point, the analysis encounters product states such as `(1, 3)` and `(2, 3)`.

The tracked values include:

```text
{[0, 0], [0, 1], [0, 2]}
```

Interleaved loop execution triggers widening to an unbounded interval:

```text
[-∞, +∞]
```

This loss of precision results in an assertion failure in the analysis.

### Case B: Bounded Precise Automata

In the second example, the analysis reaches the assertion at state 4 without premature widening.

The tracked counter remains within:

```text
[0, 2]
```

Consequently, the assertion `count <= 2` passes.



### Key Observation

The comparison illustrates the impact of control-flow structure and widening on abstract-analysis precision.

Preserving useful information for as long as possible can reduce spurious assertion failures while maintaining the termination benefits of abstract interpretation.

---

## 7. Conclusion and Ongoing Work

Effective verification of concurrent systems requires a balance between analysis precision and execution efficiency.

### Preserve Analysis Precision

- Identify and control premature widening.
- Reduce false-positive assertion failures.
- Retain useful information about program-variable values during reachability analysis.

### Optimize Verification Efficiency

- Improve targeted state-space pruning.
- Reduce redundant exploration.
- Decrease overall analysis termination time.

The broader objective is to improve the scalability and precision of static analysis for concurrent systems with complex communication and control behavior.

---

## Technologies and Concepts

| Area | Technologies / Concepts |
|---|---|
| Model checking | SPIN |
| Modeling language | Promela |
| Temporal logic | Linear Temporal Logic (LTL) |
| System properties | Safety, liveness, mutual exclusion |
| Unbounded systems | Vector Addition Systems (VAS) |
| State-space abstraction | Karp–Miller algorithm |
| Static analysis | Abstract interpretation |
| Reachability | Product states, lattice-based analysis |
| Precision control | Widening and state-space pruning |

---

## Presentation

**Event:** SERI 2026  
**Title:** Verification of Concurrent Systems  
**Institution:** IISc Bangalore

The original presentation added to this repository as `seri.pdf`.

---

## Acknowledgment

I would like to thank **Prof. Komondoor V. Raghavan** and the IISc Bangalore research environment for the opportunity to explore concurrent-system verification  through the ACM iSoft ASCENT Internship.
