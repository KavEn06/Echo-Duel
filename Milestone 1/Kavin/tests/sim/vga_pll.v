`timescale 1ns/1ps
// Icarus-only functional substitute for the supplied Intel PLL IP.
// Does not model lock, jitter or physical timing. Never add to Quartus.
module vga_pll(input wire inclk0, output reg c0);
    initial c0 = 0;
    always @(posedge inclk0) c0 <= ~c0;
endmodule
