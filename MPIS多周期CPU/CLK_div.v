`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 20:34:27
// Design Name: 
// Module Name: CLK_div
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


module CLK_div #(parameter N = 50000000)(
    input CLK_in,
    output CLK_out
    );
    
    reg [31:0]counter = 0;
    reg out = 0;
    
    always@(posedge CLK_in) begin
        if (counter==N-1) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
    
    always@(posedge CLK_in) begin
        if (counter == N-1) begin
            out <= !out;
        end
    end
    
    assign CLK_out = out;
    
endmodule
