# riscv_processor

Two-cycle RISC-V processor supporting R-, I-, and B-type instructions. Built in CircuitVerse.

---

## Live Circuit

https://circuitverse.org/users/429352/projects/processor_ribtype

The EEPROM comes preloaded with `rib_test.s`. Open the link and click the clock button to begin cycling through instructions.

---

## Overview

This processor implements a two-cycle fetch/execute architecture for a subset of the RISC-V ISA. It was designed collaboratively by a six-person team over approximately three weeks. The team divided into subteams (ALU, Control Unit, Memory, BCU/PC/IR). Liam designed the overall architecture, produced the initial datapath sketches, coordinated the subteams, built the Control Unit, wrote datapath expectations sheet based on test assembly, and performed all integration of the individual components into the final circuit.

Team: Liam (architecture, CU, integration), Madalina (CU subteam; built I and R-Type ROMs for CU and wrote the initial test assembly program which `rib_test_expectations.csv` is based on), Fhares (main memory/EEPROM), Jing (ALU), Ally (BCU + PC + IR), and Sofia (main memory subteam). Register file designed by Teddy (Amherst College).

---

## Two-Cycle Architecture

**Cycle 1 — Fetch:**
- Instruction fetched from main memory (EEPROM) into the Instruction Register (IR)
- PC held; IRWE asserted

**Cycle 2 — Execute:**
- Instruction decoded; ALU computes result
- Register file written (RFWE) for R- and I-type; branch target evaluated for B-type
- PC incremented (or redirected on taken branch)

The Cycle-Counter Control subsystem gates PCWE, IRWE, RFWE, and MMaddrMux based on the current cycle and instruction type, ensuring correct two-cycle sequencing without a pipeline.

---

## Components

| Component | Description | Builder |
|---|---|---|
| PC | 32-bit program counter with +4 increment and branch target mux | Team |
| IR | Instruction register; holds fetched instruction through execute cycle | Team |
| Register File | 32 D-flip-flops; rs1/rs2/rd selected by MUX; RFWE-gated write | Teddy (Amherst) |
| ALU | Supports add, sub, and, or, xor; comparison outputs (A=B, A<B) for branches | ALU subteam |
| Main Memory | EEPROM with MMaddrMux (selects between PC and ALU output); DI/DO ports | Fhares |
| Control Unit | Comparator → encoder → MUX architecture; includes Cycle-Counter Control | Liam + Madalina |
| BCU | Branch Control Unit; evaluates branch condition using funct3 and ALU comparison | CU subteam |

---

## Control Unit Design

The CU uses a comparator-based approach rather than a single large EEPROM:

1. Opcode is compared against known I-type, R-type, B-type, and S-type constants using dedicated "Equals X-Type" comparators.
2. Comparator outputs feed an encoder, producing a type selector signal.
3. The selector drives a MUX over constant control signal bundles, one per instruction type, routing the correct signals to the datapath.
4. Two ROM blocks (one for I-type, one for R-type) handle ALUOp decoding from funct3 and funct7 bits.
5. The Cycle-Counter Control subsystem (a 1-bit counter clocked with the processor) gates PCWE, IRWE, RFWE, and MMaddrMux, implementing the two-cycle sequencing.

This design was chosen over a monolithic EEPROM because it makes control signal intent explicit and human-readable at the gate level. Each signal path can be traced and verified independently.

Individual components in the CircuitVerse circuit can be expanded by clicking on them, exposing the underlying gate-level implementation.

---

## ISA Supported

| Type | Instructions |
|---|---|
| R-type | add, sub, and, or, xor |
| I-type | addi, andi, ori, xori |
| B-type | beq, bne, blt, bge |
| Planned (incomplete) | lw, sw |

---

## Control Signals

See `control_signals/control_signals.csv` for the full signal table. Signals controlled per instruction: ALUop, ALU BinMux, RFWE, RFinMux, MMWE, ImmMux, PCWE, IRWE, MMaddrMux, BCUop. PCWE, IRWE, RFWE, and MMaddrMux are Cycle-Counter Controlled for all instructions.

---

## Testing

Testing used the Venus RISC-V simulator to assemble `.s` programs into machine code, extract hex instruction encodings, and preload the EEPROM. The test expectations spreadsheets trace expected datapath state (IR hex, ALU output, RF outputs, PC, register values) at each instruction boundary, allowing verification by observing the labeled probes in CircuitVerse.

There are two test programs.

`testing/rib_test.s` tests R-, I-, and B-type instructions. This is the program preloaded into the circuit's EEPROM. The initial assembly was written by Madalina; `rib_test_expectations.csv` was built from that program to trace expected datapath state at each instruction.

`testing/sw_lw_test.s` tests store word and load word instructions. Written in anticipation of lw/sw implementation, which is not yet complete. Expectations are documented in `sw_lw_test_expectations.csv` for use once implementation is finished.

**How to follow the R/I/B test in CircuitVerse:**

1. Open https://circuitverse.org/simulator/processor_ribinstr
2. The EEPROM is preloaded with `rib_test.s`. Click the clock button to begin.
3. Each clock tick advances one cycle. Odd ticks are Fetch; even ticks are Execute.
4. Compare the labeled probe outputs (IR Out, ALU Mux Output, RF Output A, RF Data In, PC to MM, Immediate Value) against the corresponding row in `rib_test_expectations.csv`.

---

## Next Steps

- Implement lw/sw (memory address mode, MMWE logic, RFinMux for load path)
- Implement jalr (link address via RFinMux third option: PC+4)
- Extend toward pipelining (hazard detection, forwarding)

---

## Docs

Design sketches (datapath, ALU, CU, Cycle-Counter, BCU) will be added to `docs/`. These are the original hand-drawn diagrams produced at the start of the project, uploaded to the team's shared working document and used to coordinate subteam builds.
