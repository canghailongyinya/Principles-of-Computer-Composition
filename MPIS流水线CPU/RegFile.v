`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 19:23:08
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input Clk,
    input Clr,
    input Reg_Write,
    input [4:0] Read_Reg_Addr1,
    input [4:0] Read_Reg_Addr2,
    input [4:0] Write_Reg_Addr,
    input [31:0] Write_Reg_Data,
    output [31:0] Read_Reg_Data1,
    output [31:0] Read_Reg_Data2
    );
    reg [31:0] Regs [31:0];
    integer i;
    initial
        for (i = 0; i < 32; i = i + 1)
            Regs[i] = 0;
    always @(posedge Clk or posedge Clr)
    begin
        Regs[0] = 0;
        if (Clr) 
            for (i = 0; i < 32; i = i + 1)
                Regs[i] = 0;
    end
    always @(negedge Clk) begin
        if (Reg_Write) 
            Regs[Write_Reg_Addr] = Write_Reg_Data;
    end
    assign Read_Reg_Data1 = Regs[Read_Reg_Addr1];
    assign Read_Reg_Data2 = Regs[Read_Reg_Addr2];
endmodule
