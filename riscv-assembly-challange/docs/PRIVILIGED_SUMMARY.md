# RISC-V Privileged Architecture Summary
MEDS Module 3 — Self-Study Deliverable

## Privilege Levels

RISC-V defines three privilege levels, each with different access rights:

**Machine Mode (M-mode)**
Highest privilege level. Always present in every RISC-V implementation.
Firmware and bootloaders run here. Has direct access to all hardware
and CSRs. A minimal core (like the Module 5 design) only needs M-mode.

**Supervisor Mode (S-mode)**
Optional. The OS kernel runs here. Manages virtual memory through the
page table system. Cannot access M-mode CSRs directly.

**User Mode (U-mode)**
Optional. Regular applications run here. Most restricted — cannot touch
hardware registers or CSRs directly. Must request services through ecall,
which traps up to a higher privilege level. This is exactly why Venus
programs use ecall for I/O.

A full Linux system requires all three levels. A bare-metal embedded
system may only implement M-mode.

---

## Key CSRs (Control and Status Registers)

CSRs are special registers separate from the general-purpose x0-x31
file. They control and monitor processor behavior at the machine level.

| CSR | Purpose |
|-----|---------|
| mstatus | Global interrupt enable and current privilege mode tracking |
| mtvec | Address of the trap handler — processor jumps here on any trap |
| mepc | Exception PC — address of the instruction that caused the trap |
| mcause | Trap cause code — identifies what type of trap occurred |
| mtval | Additional trap information, e.g. the faulting memory address |

---

## Trap Handling Flow

A trap is any event that transfers control from the current execution
to the processor's trap handler. Traps include ecall, illegal
instructions, memory faults, and timer interrupts.

**Step 1 — Trap detected**
The processor detects the trap condition at the end of an instruction
cycle.

**Step 2 — Hardware saves context automatically**
- mepc ← address of the instruction that caused the trap
- mcause ← code identifying the trap type
- PC → mtvec (jumps to trap handler address)

No software intervention at this step — hardware does it atomically.

**Step 3 — Trap handler executes**
Software reads mcause to determine what happened and handles it
appropriately: serves the system call, fixes the fault, logs the error,
or terminates the process.

**Step 4 — Return with MRET**
The handler executes MRET, which restores PC from mepc and returns
to the privilege level active before the trap. Execution resumes
from where it was interrupted.

This flow is analogous to a function call — mepc acts like ra,
mtvec is the handler address, and MRET is like ret — except the
entire mechanism is triggered and set up by hardware, not software.