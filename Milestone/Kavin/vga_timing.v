`timescale 1ns/1ps
// 640x480 VGA at approximately 59.52 Hz using a 25 MHz pixel clock.
// Nominal VGA uses 25.175 MHz; verify monitor acceptance on the board.
// All sequential logic stays in the 50 MHz clock domain. Coordinates
// advance on the falling pixel-clock phase, before the monitor samples RGB.
module vga_timing (
    input wire clk,
    input wire reset,
    output reg pixel_clk,
    output reg [9:0] x,
    output reg [9:0] y,
    output wire active_video,
    output wire hsync_n,
    output wire vsync_n
);
    always @(posedge clk) begin
        if (reset) begin
            pixel_clk <= 1'b0;
            x <= 10'd0;
            y <= 10'd0;
        end else begin
            pixel_clk <= ~pixel_clk;
            if (pixel_clk) begin
                if (x == 10'd799) begin
                    x <= 10'd0;
                    if (y == 10'd524) y <= 10'd0;
                    else y <= y + 10'd1;
                end else x <= x + 10'd1;
            end
        end
    end
    assign active_video = (x < 10'd640) && (y < 10'd480);
    assign hsync_n = !((x >= 10'd656) && (x < 10'd752));
    assign vsync_n = !((y >= 10'd490) && (y < 10'd492));
endmodule
