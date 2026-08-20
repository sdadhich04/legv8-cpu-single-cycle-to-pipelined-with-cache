# LEGv8 CPU: Single-Cycle to Pipelined, with a Cache Hierarchy

Five SystemVerilog labs from **EE 469 (Computer Architecture)**, University
of Washington — building a LEGv8/ARMv8 processor (the Patterson & Hennessy
textbook ISA) from basic combinational/sequential building blocks, through
an ALU, a complete single-cycle CPU, a 5-stage pipelined CPU with
forwarding, and finally a configurable cache/memory hierarchy sitting in
front of main memory. See [Known limitations / next steps](#known-limitations--next-steps)
for real, verified gaps and bugs, not glossed over here.

## What's here

### `lab1-combinational-blocks/`

A library of primitives reused by every later lab: `D_FF.sv` /
`D_FFx32.sv` / `D_FFx64.sv` (1-bit and word-wide positive-edge D
flip-flops), `Decoder_5_32.sv` (a 5-to-32 one-hot decoder, used for
register-file write-enable), `LeftShift.sv` / `MultiLeftShift.sv` (fixed
and parameterized left shifters), `Mux_2_1.sv` / `Mux_2_1_64Bit.sv` /
`Mux_32_1.sv` / `Mux_32_1x64.sv` (2:1 and 32:1 muxes at 1-bit and 64-bit
widths), and `regfile.sv` — a 32×64-bit register file built from the
flip-flops and decoder, with `regstim.sv` as its testbench.

### `lab2-alu/`

A 64-bit ALU (`alu.sv`) selecting among sub-block results with an 8:1 mux
(`Mux_8_1x64`) driven by a 3-bit control code: `B_Test` (pass-through B),
`ADD_SUB_A_B` (a shared adder/subtractor built from 64 chained `FullAdd`
cells with an `isSUB`-controlled B-invert/carry-in), plus bitwise AND/OR/XOR
sub-blocks and `isZero.sv` for the zero flag. Each sub-block packs its own
zero/negative flags alongside its result, and the mux selects the winning
slice. See [Known limitations](#known-limitations) for a real bug in this
lab's OR sub-block wiring.

### `lab3-single-cycle-cpu/`

`Single_Cycle_CPU.sv` wires one complete LEGv8 datapath per clock cycle:
`ProgramCounter` → `instructmem` → `Opcode_Decoder` (generates control
signals) → a `Reg2Loc` mux selecting `Rd`/`Rm` into the register file's
second read port → sign/zero extenders for the D-address, ALU-immediate,
and branch-offset instruction fields → a chain of muxes selecting the
ALU's B operand → `alu` → `datamem` → a `MemToReg` mux writing the result
back to the register file. A one-cycle flip-flop holds the negative flag
for B.LT, since that condition depends on a preceding SUBS.

### `lab4-pipelined-cpu/`

`CPU.sv` implements a 5-stage LEGv8 pipeline (IF/ID, ID/EX, EX/MEM, MEM/WB)
using generic pipeline-latch flip-flops named by stage suffix (e.g.
`instruction_IF_ID`, `Da_ID_EX`/`Rd_ID_EX`, `ALU_Result_EX_MEM`,
`read_data_MEM_WB`). `ForwardingUnit.sv` computes seven forwarding selects
covering EX-EX and MEM-EX forwarding for ALU operands as well as
forwarding into branch-register (BR) and CBZ comparisons.
`BLT_FlagRegister.sv` latches the negative/overflow flags for one extra
cycle to account for B.LT's condition now depending on a SUBS a stage
earlier. See [Known limitations](#known-limitations) for a real, verified
gap: a correct `HazardDetection` module exists but isn't wired into the
pipeline. `benchmarks/` holds `.arm` test programs exercising this CPU —
immediate/flag arithmetic, branches (`B`/`CBZ`/`B.LT`), memory access
(`LDUR`/`STUR`), function calls (`BL`/`BR`), a forwarding stress test, a
bubble sort, and a Fibonacci routine using recursive call/return.

### `lab4-pipelined-cpu/alternate-implementation-lab4SparshDadhich/`

A second, independently-structured implementation of the same pipelined
CPU, using named pipeline-register modules (`IF_ID_r1.sv`, `ID_EX_r2.sv`,
`EX_MEM_r3.sv`, `MEM_WB_r4.sv`) and stage-named datapath modules
(`instruc_fetch.sv`, `instruct_dec_reg_read.sv`, `execute_addr_calc.sv`),
its own `control.sv`, and a `forwarding_unit.sv` that computes only
`ForwardA`/`ForwardB` — no hazard-detection/stall logic exists in this
implementation at all (see [Known limitations / next steps](#known-limitations--next-steps)).
It's unclear which of the two implementations was the one actually used for
the final lab demo, so both are kept here as two distinct approaches to the
same lab rather than picking one as canonical.

### `lab5-cache-memory-hierarchy/`

`lab5.sv` is a student-authored, parameterized wrapper/testbench
(`module lab5 #(parameter MODEL_NUMBER = ..., parameter
DMEM_ADDRESS_WIDTH = ...)`) that instantiates and exercises the course-
provided memory-hierarchy models: `cache.svp` (one configurable cache
level — direct-mapped vs. set-associative, LRU vs. random replacement,
write-through/write-back and write-allocate policy, parameterized and
keyed off `MODEL_NUMBER`), `write_buffer.svp` (buffers a pending write
between a cache level and the next lower level so upstream accesses can
proceed while the write drains), and `main_memory.svp` (the backing store,
with a configurable per-access delay). The `.svp` files are course-
distributed IP-protected SystemVerilog (Mentor Graphics/Siemens
`pragma protect` AES-encrypted blocks) — only their parameter/interface
documentation is human-readable, not the underlying logic; that's normal
for a course-distributed reference memory model, not something specific to
this repo.

## What's original vs. course-provided

The course provided the lab handouts/specs, the register-file write-
decoder pattern, and (for lab5) the encrypted `cache.svp` /
`write_buffer.svp` / `main_memory.svp` reference models. Everything else —
every basic building block in lab1, the ALU and its sub-blocks in lab2, the
full single-cycle datapath in lab3, both pipelined CPU implementations
(with forwarding and, in the primary implementation, an unwired hazard-
detection module) in lab4, and the `lab5.sv` wrapper exercising the
provided memory hierarchy — is the students' own design and RTL.

Credit is split by lab: Lab 1, Lab 2, Lab 4, and Lab 5 were built by
Sparsh Dadhich with Ankith; Lab 3 was built by Sparsh Dadhich with
Alexander Vuu. No file in this repo carries author-header comments
(verified by grepping every `.sv`/`.svp` file for name/author patterns —
none found), so this per-lab credit comes from student confirmation rather
than embedded source metadata.

## Known limitations / next steps

- **Lab 2's `alu.sv` has a genuine module-name mismatch.** It instantiates
  a module `Bit_a_or_b`, but no file or module by that exact name exists
  anywhere in the repo — only `BitAOrB.sv` (`module BitAOrB(...)`), a
  differently-capitalized/named file. This would fail elaboration as
  committed in lab2. Notably, **this was fixed by lab3** — `lab3-single-
  cycle-cpu/alu.sv` (and lab4's copy) correctly instantiates `BitAOrB`, so
  the bug is isolated to lab2's snapshot of the file and reproduced here
  exactly as it was in that lab's submission, not silently patched.
- **Lab 4's primary implementation (`CPU.sv`) has a load-use hazard gap.**
  A correct `HazardDetection` module exists (`if((Rm == ID_EX_Rd || Rn ==
  ID_EX_Rd) && ID_EX_MEM_Read) stall = 1'b1;`), but its instantiation in
  `CPU.sv` is commented out (`//HazardDetection HazardDetectionUnit(...)`)
  and no `stall` signal gates the pipeline anywhere else in the file. So
  the primary pipeline handles register-register hazards via forwarding,
  but a load immediately followed by a dependent instruction is not
  stalled — a real functional gap, left as-is rather than silently fixed.
  The alternate implementation's `forwarding_unit.sv` has no
  hazard-detection/stall logic of any kind either (it computes only
  `ForwardA`/`ForwardB`), so neither implementation handles this case.
- **It isn't clear which lab4 implementation was the one actually used for
  the final lab demo** — both are genuinely different code, not a draft vs.
  a final version, so both are included rather than guessing which one to
  keep.
- No AI-assistance disclosure comments (ChatGPT/Claude/Codex) were found
  anywhere in this repo's source.

## Running this code

These are SystemVerilog modules and testbenches, intended for a simulator
such as ModelSim/QuestaSim (`lab5-cache-memory-hierarchy/`'s `.svp` files
specifically require Questa/ModelSim's IP-protection support to decrypt at
simulate time — they won't elaborate in an open-source simulator like
Verilator or Icarus). Each lab's testbench (`regstim.sv`, `alustim.sv`, the
testbench inside `Opcode_Decoder.sv`/`CPU.sv`, `lab5.sv`'s included
`lab5_testbench`) is the entry point for simulating that lab. Lab 4's
`benchmarks/*.arm` files are pre-assembled instruction memory images for
the CPU's `instructmem`/`instruc_fetch` module to load.

## License

MIT — see [LICENSE](LICENSE).
