`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/18 13:04:10
// Design Name: 
// Module Name: InstMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InstMem(
    input [7:0] addra,
    output [31:0] douta
    );
    reg [63:0] instmem [63:0];
    initial begin
        instmem[0] = 32'hffffffff;
        instmem[1] = 32'h20010009;
        instmem[2] = 32'h00001020;
        instmem[3] = 32'h00002020;
        instmem[4] = 32'h8c860000;
        instmem[5] = 32'h20870001;
        instmem[6] = 32'h8ce80000;
        instmem[7] = 32'h00c8482a;
        instmem[8] = 32'h1520000b;
        instmem[9] = 32'hace60000;
        instmem[10] = 32'hac880000;
        instmem[11] = 32'h20840001;
        instmem[12] = 32'h0081282a;
        instmem[13] = 32'h14a00004;
        instmem[14] = 32'h20420001;
        instmem[15] = 32'h0041182a;
        instmem[16] = 32'h14600003;
        instmem[17] = 32'h00000000;
        instmem[18] = 32'h00000000;
    end
    assign douta = instmem[addra];
endmodule
