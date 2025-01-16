`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 15:51:11
// Design Name: 
// Module Name: debounce
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


module debounce (
    input Clk,
    input btn_in,
    output reg btn_out 
);
    reg [19:0] count; 
    reg btn_in_d; 
    
    always @(posedge Clk) begin
        btn_in_d <= btn_in; 
        if (btn_in == btn_in_d) begin
            if (count == 20'hFFFFF) begin
                btn_out <= btn_in; 
            end else begin
                count <= count + 1'b1;
            end
        end else begin
            count <= 0; 
        end
    end
endmodule
