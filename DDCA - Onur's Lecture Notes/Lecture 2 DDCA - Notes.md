# Digital Design & Computer Architecture - Lecture 2
### Combinational Logic | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

Boolean algebra, canonical forms (SOP and POS), logic simplification, and the main combinational building blocks: decoders, multiplexers, full adders, PLAs, comparators, ALUs, and tri-state buffers.

---

## Two Types of Logic Circuits

**Combinational logic** — no memory, output depends only on current inputs. Same inputs always produce the same output. Everything in this lecture is combinational.

**Sequential logic** — has memory, output depends on history of inputs too. Coming in later lectures.

Any logic circuit has inputs, outputs, a functional specification (what it does), and a timing specification (how fast it responds).

---

## Boolean Algebra

Boolean algebra is regular algebra restricted to 1s and 0s, using AND, OR, and NOT. The basic identities that come up constantly when simplifying circuits:

| Rule | Meaning |
|------|---------|
| X + 0 = X | OR with 0 does nothing |
| X • 1 = X | AND with 1 does nothing |
| X + 1 = 1 | OR with 1 always gives 1 |
| X • 0 = 0 | AND with 0 always gives 0 |
| X + X = X | OR with yourself = yourself |
| X • X = X | AND with yourself = yourself |
| X + X̄ = 1 | OR with complement = 1 |
| X • X̄ = 0 | AND with complement = 0 |
| X̄̄ = X | Double complement cancels |

**Duality**: every Boolean law comes in a pair — swap AND↔OR and 0↔1 and it's still true. Distributive law `A • (B + C) = (A • B) + (A • C)` has dual `A + (B • C) = (A + B) • (A + C)`.

**DeMorgan's Law** — the most used one: `NOT(A AND B) = (NOT A) OR (NOT B)` and `NOT(A OR B) = (NOT A) AND (NOT B)`. This lets you convert between gate types — if you only have NAND gates you can still build anything.

---

## Canonical Forms

There are infinitely many ways to write the same Boolean function. Canonical forms standardize the representation so simplification can be automated.

### Sum of Products (SOP)

Find every row in the truth table where the output is 1. Write an AND expression for each (called a **minterm** — AND of all input variables, complemented if the input is 0 in that row). OR all minterms together.

Written as `F = Σm(3, 4, 5, 6, 7)`. Maps directly to a two-level AND-OR circuit. Not automatically minimal — simplification still needed.

### Product of Sums (POS)

Find every row where the output is 0. Write an OR expression for each (called a **maxterm** — OR of all inputs, but 0 in the input → true literal, 1 → complemented literal, opposite of SOP). AND all maxterms together.

Written as `F = ΠM(0, 1, 2)`.

Use SOP when there are fewer 1s in the output, POS when there are fewer 0s.

---

## Logic Simplification

The uniting theorem is the core idea: `AB + AB̄ = A`. Two minterms that differ in exactly one variable can be combined and that variable drops out. If an input can change without affecting the output, it's irrelevant and doesn't belong in the expression.

Example: `~A•~B•C + ~A•B•C` — both have `~A` and `C`, only B differs → simplifies to `~A•C`.

This is what EDA tools do at scale. Karnaugh Maps (K-Maps) are a visual method for spotting these pairs — covered in H&H Section 2.7.

---

## Combinational Building Blocks

### Decoder

N inputs → 2ⁿ outputs. Exactly one output is HIGH at any time — the one matching the input pattern. A 2-to-4 decoder with input `10` drives output line 2 HIGH, all others LOW. Used for memory addressing and instruction decoding in CPUs.

### Multiplexer (MUX)

N data inputs → 1 output, selected by a control input. A 2-to-1 MUX: select=0 passes input A, select=1 passes input B. log₂N select bits needed for N inputs.

MUXes can implement any logic function by loading the truth table values as data inputs and using the input variables as select lines. This is exactly how **LUTs (Look-Up Tables) in FPGAs work**.

### Full Adder

Adds two 1-bit numbers plus a carry-in, produces a sum bit and carry-out. Sum = 3-input XOR. Carry-out = majority function (output 1 when at least 2 of 3 inputs are 1).

Chain multiple full adders together for multi-bit addition. The **Ripple Carry Adder** is the simplest version — carry propagates from bit to bit sequentially, easy to understand but slow for large widths. The **Carry Lookahead Adder** pre-computes carries in parallel, much faster.

### Programmable Logic Array (PLA)

An array of AND gates feeding an array of OR gates — directly implements SOP form. Programmable by choosing which AND outputs connect to which OR inputs. For n inputs: 2ⁿ AND gates (one per minterm). This is the conceptual precursor to FPGAs.

### Comparator

Checks if two N-bit values are equal. XOR each pair of bits (XOR outputs 1 when inputs differ), then OR all results — if any XOR is 1, the values are not equal.

### ALU (Arithmetic Logic Unit)

Bundles multiple operations (ADD, SUB, AND, OR, XOR, compare) into one block, executing one at a time based on a control input. The core of every CPU — the part that does the actual computation.

### Tri-State Buffer

Three output states: HIGH (1), LOW (0), and floating/Z (disconnected). When disabled, the output is completely decoupled from the wire. Used when multiple devices share a bus — only one drives at a time, the rest go to Z to avoid conflicts.

---

## Logical Completeness

{AND, OR, NOT} is logically complete — any truth table can be implemented using only these three. NAND alone is also logically complete, as is NOR alone. This is why they're called universal gates.

---
