# Kavin milestone starter - course VGA integration

Milestone 1: basic note display and initial game controller. The official
ECE241 VGA adapter replaces the initial custom timing implementation.

- [x] Download course VGA adapter and DE1-SoC examples from Quercus.
- [x] Preserve supplied adapter files unchanged and record source checksums.
- [x] Drive the supplied pixel-write interface with a tested 160x120 scene writer.
- [x] Keep the tested initial phase controller and eight-note display.
- [x] Add a switch-controlled board bring-up top and course pin assignments.
- [x] Test framebuffer writes and VGA output using the actual course adapter/
  controller plus explicitly scoped Icarus RAM/PLL models.
- [ ] Run Quartus timing/synthesis, ModelSim with Intel libraries, and board checks on ECF.
- [ ] Integrate Saajan's keyboard/audio path for the playable-keyboard milestone.

Readability revision: combined rendering and pixel walking in `frame_writer.v`,
using native 160x120 coordinates and named nine-bit colours. Removed the separate
renderer file and combined its key/border checks into the writer testbench.
The game FSM now uses one clocked case statement with the same transitions.
