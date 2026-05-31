# sw_lw_test.s
# Store word / load word test program for the two-cycle RISC-V processor.
#
# NOTE: lw and sw are NOT yet implemented in the current circuit. This program
# is written in anticipation of that implementation phase. sw_lw_test_expectations.csv
# documents expected datapath behavior for each instruction; use it to verify
# correctness once lw/sw are complete.
#
# The instruction sequence is the same as rib_test.s. The focus here is on
# the sw and lw rows: sw should write s1 (17) to address t0+4, and the
# subsequent lw should reload that value into t1. The final add verifies
# the lw loaded correctly by producing a known result in s2.

.text
.globl _start
_start:

addi s1, zero, 17       # Initialize s1 = 17 (0x11).
                        # IR: 0x01100493. ALUOut: 0...10001.

lui t0, 0x00000         # Initialize t0 upper bits = 0.
                        # IR: 0x000002B7. t0 = 0.

addi t0, t0, 0x018      # t0 = 24 (0x18); this will be the base address.
                        # IR: 0x01828293. ALUOut: 0...11000.

sw s1, 4(t0)            # Store s1 (17) to memory address t0+4 = 28.
                        # IR: 0x0092A223. ALUOut: 0...11100 (base 24 + offset 4).
                        # Expected: memory[28] = 17. RFWE = 0 (no register write).

lw t1, 4(t0)            # Load word from address t0+4 = 28 into t1.
                        # IR: 0x0042A303. ALUOut: 0...11100.
                        # Expected: t1 = 17 (value written by sw above).
                        # MMtoRFMux selects memory output; RFWE = 1.

add s2, s1, t1          # s2 = s1 + t1 = 17 + 17 = 34.
                        # IR: 0x00648933. ALUOut: 0...100010.
                        # Verifies lw loaded correctly: if s2 = 34, the full
                        # sw -> lw -> add path executed as intended.
