# Course source attribution

Official ECE241 VGA resources (accessed 2026-11-19):
https://q.utoronto.ca/courses/468637/pages/vga-adapter

- `vga_adapter/`: all five files from `vga_adapter.zip` (Canvas file 45693132),
  copied byte-for-byte, including the original comments and default rainbow MIF.
- `kavin.qsf`: the clock, VGA, SW[3:0] and KEY[0] pin/IO-standard assignments
  are extracted from `DE1-SoC.zip` (Canvas file 45693159),
  `DE1-SoC/colors/vga_demo.qsf`. Other project settings are for this project.
- The adapter instantiation follows the supplied COLORS example's
  `color`, `x`, `y`, `write`, `clock`, `resetn` interface.

The note renderer, framebuffer writer, game controller and board wrapper are
project-specific starter code prepared with AI assistance. The course adapter
is supplied code; do not count it as your own implementation. Be prepared to
explain and adapt the project-specific logic for the milestone demonstration.

## Original adapter SHA-256 hashes

- `rainbow_640_9.mif`: `439117360aaeaaccf15d9b04b938577d014ac52731faf8ad72c1876e71421ec7`
- `vga_adapter.v`: `f47b7b3ef9e783e692698d5a89a58b2a48df7bd5e11998bc21d122ccd0788658`
- `vga_address_translator.v`: `494b8c4ea5027e8ecf43b1a71a596c83566a2f45f193d6d06d26340c3a68ffe4`
- `vga_controller.v`: `05d3d524c723c95301bf88ee2767517ce88698c8bfeebfd9bfd40a3211b5f8d3`
- `vga_pll.v`: `287d36a613a89892cf98114e88575e56f32a340cfc0a842f6df36bbdd9384575`
