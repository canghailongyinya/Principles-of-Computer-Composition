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
    reg [31:0] instmem [63:0];

    initial begin
        instmem[0] = 32'hffffffff;  //halt
        instmem[1] = 32'h20010009;  //addi $1,$0,9
        instmem[2] = 32'h00001020;  //add $2,$0,$0
        instmem[3] = 32'h00002020;  //add $4,$0,$0
        instmem[4] = 32'h8c860000;  //lw $6,0($4)
        instmem[5] = 32'h20870001;  //addi $7,$4,1
        instmem[6] = 32'h8ce80000;  //lw $8,0($7)
        instmem[7] = 32'h00c8482a;  //slt $9,$6,$8
        instmem[8] = 32'h1520000b;  //bne $9,$0,11
        instmem[9] = 32'hace60000;  //sw $6,0($7)
        instmem[10] = 32'hac880000; //sw $8,0($4)
        instmem[11] = 32'h20840001; //addi $4,$4,1
        instmem[12] = 32'h0081282a; //slt $5,$4,$1
        instmem[13] = 32'h14a00004; //bne $5,$0,4
        instmem[14] = 32'h20420001; //addi $2,$2,1
        instmem[15] = 32'h0041182a; //slt $3,$2,$1
        instmem[16] = 32'h14600003; //bne $3,$0,3
    end

    assign douta = instmem[addra];
endmodule
