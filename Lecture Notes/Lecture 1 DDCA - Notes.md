# Digital Design & Computer Architecture — Lecture 1

## What is this course really about?

This course is about one main idea:

**How does a computer actually work — from the lowest level (electrons) all the way up to software?**

Not just “it runs code,” but:
- how electricity becomes logic  
- how logic becomes hardware  
- how hardware runs programs  
- and how programs solve real-world problems  

---

## The Big Picture: Everything is Layers

A problem doesn’t directly get solved by a computer. It goes through multiple steps:

Problem  
→ Algorithm  
→ Program  
→ System Software (OS, etc.)  
→ ISA  
→ Microarchitecture  
→ Logic Gates  
→ Transistors  
→ Electrons  

At the end of the day:

**Your code is literally controlling electrons.**

Each layer hides complexity, but the key idea is:

**Better performance comes from understanding multiple layers together, not just one.**

---

## What is Computer Architecture?

Computer Architecture is:

**Designing computing systems based on specific goals**

Different systems have different priorities:

- Phone → battery life, size  
- Supercomputer → performance  
- Self-driving car → safety, real-time response  
- AI chip → high throughput  

There is no single “best design” — it's always about trade-offs.

---

## General vs Specialized Hardware

Think of hardware like tools:

### CPU (General Purpose)
- Works for everything  
- Easy to use  
- Moderate performance  

Like an adjustable wrench.

---

### FPGA (Reconfigurable)
- Can be programmed at hardware level  
- Better performance than CPU  
- Still flexible  

---

### ASIC (Custom Chip)
- Built for one specific task  
- Highest performance  
- Cannot be changed after design  

Like a perfectly sized wrench.

---

Key idea:

Flexibility ↓ → Performance ↑  
Performance ↑ → Development Time ↑  

---

## The Foundation: Transistors

Everything in a computer is built from **transistors**.

A transistor is simply:

**A switch**
- ON → current flows  
- OFF → no current  

---

## Types of Transistors

- nMOS → turns ON when input is HIGH  
- pMOS → turns ON when input is LOW  

They behave in opposite ways.

---

## Why CMOS is Important

Modern circuits use **CMOS (Complementary MOS)**.

The idea:
- nMOS and pMOS are used together  
- When one is ON, the other is OFF  

This means:
- No direct path from power to ground  
- Very low power consumption  

That’s why CMOS is widely used.

---

## Example: NOT Gate

A NOT gate simply flips the input:

Input → Output  
0 → 1  
1 → 0  

Internally:
- pMOS pulls output HIGH  
- nMOS pulls output LOW  

---

## Logic Gates

By combining transistors, we build logic gates:

- NOT → invert input  
- AND → both inputs must be 1  
- OR → at least one input is 1  
- NAND → AND + NOT  
- NOR → OR + NOT  

---

## Important Concept: NAND is Universal

**Any logic function can be built using only NAND gates.**

Same is true for NOR.

That’s why they are heavily used in real hardware.

---

## CMOS Design Rule

Each CMOS circuit has:

- Pull-up network (pMOS) → connects to power  
- Pull-down network (nMOS) → connects to ground  

Important rule:

- Only one should be ON at a time  

If both ON → short circuit  
If both OFF → undefined output  

---

## Why This Course Matters

Even if you write software:

- You understand performance better  
- You write more efficient code  
- You make smarter design decisions  

Also, computing is evolving:

- Moore’s Law slowing down  
- Rise of AI chips, accelerators  
- More specialized hardware  

---

## Key Terms to Know

- ISA → interface between hardware and software  
- Microarchitecture → how hardware is implemented  
- FPGA → programmable hardware  
- ASIC → fixed custom hardware  
- CMOS → efficient transistor design  
- NAND/NOR → universal logic gates  

---

## Final Thought

A computer is:

**A system that converts ideas into electrical signals — and back into useful results.**

And this course is about understanding that full journey.