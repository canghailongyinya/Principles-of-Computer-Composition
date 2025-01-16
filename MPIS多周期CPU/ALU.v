`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 19:30:35
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] input1,
    input [31:0] input2,
    input [3:0] AluCtrl,
    input EX,
    output reg [31:0] result,
    output reg zero
    );
    always @(*) 
    begin
        if (EX == 1) begin
            case (AluCtrl)
                4'b0000: result = input1 & input2;
                4'b0001: result = input1 | input2;
                4'b0010: result = input1 + input2;
                4'b0110: result = input1 - input2;
                4'b0111: result = input1 < input2;
                4'b1100: result = input1 << input2;
                default: result = 0;
            endcase
            if (result == 0) zero = 1;
            else zero = 0;
        end
    end
endmodule
