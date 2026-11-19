`timescale 1ns/1ps
// Narrow Icarus-only model of the dual-port RAM configuration used by
// the course adapter. NOT a general Intel IP model. Never synthesize.
// Zero initialization matches this project's black MIF; MIF parsing and
// mixed-port read-during-write collision behavior are not modeled.
module altsyncram #(
    parameter width_a=9, width_b=9, widthad_a=15, widthad_b=15,
    parameter numwords_a=19200, numwords_b=19200,
    parameter intended_device_family="Cyclone V", operation_mode="DUAL_PORT",
    parameter outdata_reg_b="CLOCK1", address_reg_b="CLOCK1",
    parameter clock_enable_input_a="BYPASS", clock_enable_input_b="BYPASS",
    parameter clock_enable_output_b="BYPASS", power_up_uninitialized="FALSE",
    parameter init_file=""
)(
    input wire wren_a,wren_b,clock0,clock1,clocken0,clocken1,
    input wire [widthad_a-1:0] address_a,
    input wire [widthad_b-1:0] address_b,
    input wire [width_a-1:0] data_a,
    output reg [width_b-1:0] q_b
);
    reg [width_a-1:0] mem [0:numwords_a-1];
    reg [widthad_b-1:0] read_address;
    integer i;
    initial begin
        read_address=0; q_b=0;
        for(i=0;i<numwords_a;i=i+1) mem[i]=0;
    end
    always @(posedge clock0)
        if(clocken0 && wren_a && address_a<numwords_a) mem[address_a] <= data_a;
    always @(posedge clock1) begin
        if(clocken1) begin
            read_address <= address_b;
            if(read_address<numwords_b) q_b <= mem[read_address];
            else q_b <= 0;
        end
    end
endmodule
