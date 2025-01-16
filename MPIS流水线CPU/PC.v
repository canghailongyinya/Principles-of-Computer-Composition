`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 09:06:22
// Design Name: 
// Module Name: PC
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


module PC(
    input Clk,
    input Clr,
    input [25:0] inst1,
    input [15:0] inst2,
    input Branch,
    input Jump,
    input crash,
    input over,
    output reg [7:0] PC,
    output reg sortover
    );
    initial begin
        sortover = 0;
    end
    always @(posedge Clk or posedge Clr) begin
        if (Clr) begin
            PC = 8'b0;
            sortover = 0;
        end else if (over == 1 && sortover == 0) begin
            //排序过程中···
            if (PC == 8'b00010011) begin  //17(00010001)   +24=41
                PC = 8'b0;//////////
                sortover = 1;           
            end 
            else if (Branch) begin
                PC = inst2[15:0];
            end
            else if (Jump == 1) begin
                PC = inst1[25:0];
            end
            else if (crash == 1) begin
                //不增
            end
            else PC = PC + 1'b1;
        end else begin
            PC = 8'b0;
        end
    end
endmodule
