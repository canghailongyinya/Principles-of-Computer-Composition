`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 15:40:25
// Design Name: 
// Module Name: DataMem
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


module DataMem(
    input clk,
    input clr,
    input write_enable_btn,
    input Mem_Write,
    //input Mem_Read,
    input [15:0] Mem_write_data,    //输入
    input [3:0] Mem_read_addr,
    input [3:0] Mem_write_addr,
    output [15:0] Mem_read_data,
    output reg [9:0] display_led,
    output reg over

    //output reg [3:0] Mem_write_addr2
    );
    //reg write_enable;
    reg [15:0] data [9:0];     //10个16位数
    reg [3:0] Mem_write_addr2;
    
    initial begin
        //write_enable = 1;
        Mem_write_addr2 = 0;
        display_led = 10'b1000000000;
        over = 0;
    end 
    reg [3:0] Mem_write_addr3;
    always @(posedge write_enable_btn or posedge clr) begin
        if (clr == 1) begin
            Mem_write_addr2 = 0;
            display_led = 10'b1000000000;
            over = 0;
        end else if (over == 0 && Mem_write_addr2 < 10) begin
            //data[Mem_write_addr2] <= Mem_write_data;
            //Mem_write_addr3 = Mem_write_addr2;
            //display_data <= in_data;
            Mem_write_addr2 = Mem_write_addr2 + 1;
            case (Mem_write_addr2)
                4'b0001: display_led <= 10'b0100000000;
                4'b0010: display_led <= 10'b0010000000;
                4'b0011: display_led <= 10'b0001000000;
                4'b0100: display_led <= 10'b0000100000;
                4'b0101: display_led <= 10'b0000010000;
                4'b0110: display_led <= 10'b0000001000;
                4'b0111: display_led <= 10'b0000000100;
                4'b1000: display_led <= 10'b0000000010;
                4'b1001: display_led <= 10'b0000000001;
                default: display_led <= 10'b1000000000;
            endcase
            if (Mem_write_addr2 == 10 ) begin
                //write_enable <= 0;
                display_led <= 10'b1000000000;
                over <= 1;
            end 
        // end else if (over == 1 && Mem_Write == 1) begin
        //     data[Mem_write_addr] <= Mem_write_data;
        // end
        end
    end

    // always @(posedge clk) begin
    //     if (over == 1 && Mem_Write == 1) begin
    //         //data[Mem_write_addr] <= Mem_write_data;
    //     end
    // end

    always @(posedge clk) begin
        Mem_write_addr3 = over ? Mem_write_addr : Mem_write_addr2;
        if (over == 0 || Mem_Write == 1) begin
            data[Mem_write_addr3] <= Mem_write_data;
        end
    end

    // always @(*) begin
    //     out_data = data[Mem_read_addr];
    //     //Mem_write_addr2 <= Mem_write_addr;
    // end
    // always @(*) begin
    //     if (Mem_Write == 1) begin
    //         data[Mem_write_addr] = Mem_write_data;
    //     end
    // end

    assign Mem_read_data = data[Mem_read_addr];

endmodule
