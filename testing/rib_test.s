# rib_test.s
# R-, I-, and B-type instruction test program for the two-cycle RISC-V processor.
# Original assembly by Madalina (CU subteam). This file was created by Claude Code but based on the assembly from a .csv (Google Sheet) encapsulating expectations across the datapath during the .s test program.
# This program is preloaded into the circuit's EEPROM; use rib_test_expectations.csv to verify datapath state.
# How to run: open https://circuitverse.org/simulator/processor_ribinstr
# and click the clock button. Odd ticks = Fetch, even ticks = Execute.
# Compare labeled probe outputs against rib_test_expectations.csv row by row.

.text
.globl _start
_start:

# --- I-type ---

addi s1, zero, 17       # Load immediate 17 (0x11) into s1.
                        # IR: 0x01100493. Expected: s1 = 17, ALUOut = 0...10001.

lui t0, 0x00000         # Load upper immediate 0 into t0.
                        # IR: 0x000002B7. Expected: t0 = 0.

addi t0, t0, 0x018      # Add 24 (0x18) to t0.
                        # IR: 0x01828293. Expected: t0 = 24 (0...11000).

# --- S-type (not yet implemented; included for sequence completeness) ---

sw s1, 4(t0)            # Store s1 (17) to memory address t0+4 = 28.
                        # IR: 0x0092A223. ALUOut: 0...11100.
                        # NOTE: sw is not yet implemented; this instruction
                        # will not write memory in the current circuit.

# --- Load (not yet implemented) ---

lw t1, 4(t0)            # Load word from address t0+4 into t1.
                        # IR: 0x0042A303. Expected: t1 = 17 (pending lw implementation).
                        # NOTE: lw is not yet implemented; t1 will not reflect
                        # the stored value in the current circuit.

# --- R-type ---

add s2, s1, t1          # s2 = s1 + t1 = 17 + 17 = 34.
                        # IR: 0x00648933. Expected: s2 = 34 (0...100010).
                        # Verifies R-type ALU operation end-to-end.

# --- B-type setup: load known values for branch tests ---

addi a0, zero, 5        # a0 = 5
addi a1, zero, 5        # a1 = 5 (equal to a0; beq should be taken)
addi a2, zero, 3        # a2 = 3 (less than a0; blt a0,a2 not taken; blt a2,a0 taken)

# --- B-type tests ---

beq a0, a1, branch_eq   # a0 == a1 (5 == 5): branch taken.
                        # IR encodes funct3=000, BCUop=100.
addi t2, zero, 0        # Skipped if branch taken (sentinel: t2 stays 0 on taken path).

branch_eq:
bne a0, a1, branch_ne   # a0 != a1? No (5 == 5): branch NOT taken.
                        # IR encodes funct3=001, BCUop=101.
                        # Execution continues to next instruction.

addi t3, zero, 1        # Reached because bne is not taken (t3 = 1 confirms fall-through).

branch_ne:
blt a2, a0, branch_lt   # a2 < a0? Yes (3 < 5): branch taken.
                        # IR encodes funct3=100, BCUop=110.

addi t4, zero, 0        # Skipped if blt taken.

branch_lt:
bge a0, a2, branch_ge   # a0 >= a2? Yes (5 >= 3): branch taken.
                        # IR encodes funct3=101, BCUop=111.

addi t5, zero, 0        # Skipped if bge taken.

branch_ge:
# End of test sequence.
