`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 19:29:34
// Design Name: 
// Module Name: AluCtrl
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


module AluCtrl(
    input Clk,
    input [31:0] inst,
    output reg [3:0] AluCtrl,
    output reg Reg_Dst,
    output reg ALU_Src1,
    output reg ALU_Src2,
    output reg Mem_Write,
    output reg Mem_Read,
    output reg MemtoReg,
    output reg Reg_Write,
    output reg Halt
    );
    wire [31:26] opcode;
    wire [5:0] funct;
    assign opcode = inst[31:26];
    assign funct = inst[5:0];
    always @(negedge Clk) begin
        case (opcode)
            6'b000000: begin // r-type
                Reg_Dst = 1;
                ALU_Src2 = 0; 
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0; //直接从ALU写回寄存器
                Reg_Write = 1;
                Halt = 0;
                case (funct)
                    6'b100000: begin
                        AluCtrl = 4'b0010; // add
                        ALU_Src1 = 0;
                    end
                    6'b100010: begin
                        AluCtrl = 4'b0110; // sub
                        ALU_Src1 = 0;
                    end
                    6'b100100: begin    
                        AluCtrl = 4'b0000; // and
                        ALU_Src1 = 0;
                    end
                    6'b100101: begin
                        AluCtrl = 4'b0001; // or
                        ALU_Src1 = 0;
                    end
                    6'b101010: begin
                        AluCtrl = 4'b0111; // slt
                        ALU_Src1 = 0;
                    end
                    6'b000000: begin
                        AluCtrl = 4'b1100; // sll                       
                        ALU_Src1 = 1;
                    end
                endcase
            end
            6'b001000: begin
                AluCtrl = 4'b0010; // addi
                Reg_Dst = 0; //写回寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 1; //第二个源操作数为立即数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 1;
                Halt = 0;
            end
            6'b001100: begin
                AluCtrl = 4'b0000; // andi
                Reg_Dst = 0; //写回寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 1; //第二个源操作数为立即数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 1;
                Halt = 0;
            end
            6'b001101: begin
                AluCtrl = 4'b0001; // ori
                Reg_Dst = 0; //写回寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 1; //第二个源操作数为立即数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 1;
                Halt = 0;
            end
            6'b100011: begin
                AluCtrl = 4'b0010; // lw
                Reg_Dst = 0; //目标寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 1; //第二个源操作数为立即数
                Mem_Write = 0;
                Mem_Read = 1;
                MemtoReg = 1;
                Reg_Write = 1;
                Halt = 0;
            end
            6'b101011: begin
                AluCtrl = 4'b0010; // sw
                Reg_Dst = 0; //目标寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 1; //第二个源操作数为立即数
                Mem_Write = 1;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 0;
                Halt = 0;
            end
            6'b000100: begin
                AluCtrl = 4'b0110; // beq
                Reg_Dst = 0; //无关
                ALU_Src1 = 0;
                ALU_Src2 = 0; //第二个源操作数为寄存器数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 0;
                Halt = 0;
            end
            6'b000101: begin
                AluCtrl = 4'b0110; // bne
                //Reg_Dst无关
                Reg_Dst = 0; //目标寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 0; //第二个源操作数为寄存器数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 0;
                Halt = 0;
            end
            6'b000010: begin
                AluCtrl = 4'b0010; // j
                //ALU_Src2无关
                //Reg_Dst无关
                Reg_Dst = 0; //无关
                ALU_Src1 = 0;
                ALU_Src2 = 0; //无关
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 0;
                Halt = 0;
            end
            6'b111111: begin
                AluCtrl = 4'b1111; // halt
                //ALU_Src2无关
                //Reg_Dst无关
                Reg_Dst = 0; //目标寄存器地址为rt
                ALU_Src1 = 0;
                ALU_Src2 = 0; //第二个源操作数为寄存器数
                Mem_Write = 0;
                Mem_Read = 0;
                MemtoReg = 0;
                Reg_Write = 0;
                Halt = 1;
            end
        endcase
    end
endmodule
