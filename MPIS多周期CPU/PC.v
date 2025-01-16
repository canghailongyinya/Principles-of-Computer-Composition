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
    input [31:0] inst,
    input Branch,
    input Jump,
    input [15:0] result,
    input over,
    input IF,
    output reg [7:0] PC,
    output reg sortover
    );
    initial begin
        sortover = 0;
    end
        //读取指令
    always @(posedge Clk or posedge Clr) begin
        if (Clr) begin
            PC = 8'b0;
            sortover = 0;
        end else if (over == 1 && sortover == 0) begin
            if (IF == 1) begin 
                //排序过程中···
                if (PC == 8'b00010001) begin 
                    PC = 8'b0;//////////
                    sortover = 1;           
                end 
                else if (Branch == 1 && (inst[26] ^ result == 0)) begin
                    PC = inst[15:0];
                end
                else if (Jump == 1) begin
                    PC = inst[25:0];
                end
                else PC = PC + 1'b1;
            end
        end else begin
            PC = 8'b0;
        end
    end

endmodule
