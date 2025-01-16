`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 19:26:41
// Design Name: 
// Module Name: top
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


module top(
    input Clk,
    input Clr,
 
    input btn_in, 
    input [15:0] Mem_write_data,

    output reg [9:0] display_led3,
    output over, //输入阶段结束标志
    output sortover, //排序阶段结束标志

    output wire [6:0] sm_duan,
    output wire [3:0] sm_wei
    );

    wire [9:0] display_led;

    wire [7:0] PC;
    wire [31:0] inst;
    wire [3:0] AluCtrl;
    wire [4:0] Read_Reg_Addr1;
    wire [4:0] Read_Reg_Addr2;
    reg [4:0] Write_Reg_Addr;

    wire Reg_Dst;
    wire ALU_Src1;
    wire ALU_Src2;
    wire Mem_Write;
    wire Mem_Read;
    wire MemtoReg;
    wire Reg_Write;
    wire Branch;
    wire Jump;
    wire Halt;
    wire [2:0] stage;

    wire write_enable_btn;
    wire [15:0] Mem_read_data; //数据存储器读出的数据

    wire [15:0] display_data; //显示的数据

    reg IF;
    reg ID;
    reg EX;
    reg MEM;
    reg WB;
    reg [7:0] cnt;

    initial begin
        IF = 1;
        ID = 0;
        EX = 0;
        MEM = 0;
        WB = 0;
        cnt = 0;
    end

    always @(posedge Clk or posedge Clr) begin
        if (Clr) begin
            IF = 1;
            ID = 0;
            EX = 0;
            MEM = 0;
            WB = 0;
        end else if (cnt<100) begin
            cnt = cnt + 1;
            if (IF == 1) begin 
                IF = 0;
                ID = 1;
            end else if (ID == 1) begin
                ID = 0;
                if (stage[2] == 1) begin
                    EX = 1;
                end else if (stage[1] == 1) begin
                    MEM = 1;
                end else if (stage[0] == 1) begin
                    WB = 1;
                end else begin
                    IF = 1;
                end
            end else if (EX == 1) begin
                EX = 0;
                if (stage[1] == 1) begin
                    MEM = 1;
                end else if (stage[0] == 1) begin
                    WB = 1;
                end else begin
                    IF = 1;
                end
            end else if (MEM == 1) begin
                MEM = 0;
                if (stage[0] == 1) begin
                    WB = 1;
                end else begin
                    IF = 1;
                end
            end else if (WB == 1) begin
                WB = 0;
                IF = 1;
            end
        end
    end

    wire clk_div;
    CLK_div Clk_div (
        .CLK_in(Clk),
        .CLK_out(clk_div)
    );

    debounce db (
        .Clk(Clk),
        .btn_in(btn_in),
        .btn_out(write_enable_btn)
    );

    //输入数据
    reg [3:0] Mem_read_addr3;
    reg [15:0] Mem_write_data3;
    reg [3:0] Mem_write_addr;
    reg [3:0] Mem_read_addr;
    DataMem dataMem (
        .clk(Clk),
        .clr(Clr),
        //.write_enable_btn(write_enable_btn),
        .write_enable_btn(btn_in),
        .Mem_Write(Mem_Write),
        .Mem_write_data(Mem_write_data3),
        .Mem_write_addr(Mem_write_addr),
        .Mem_read_addr(Mem_read_addr3),
        .Mem_read_data(Mem_read_data),
        .MEM(MEM),
        .display_led(display_led),
        .over(over)
    );

    assign display_data = over ? Mem_read_data : Mem_write_data;
    //显示数据
    display display (
        .clk(Clk),          // input wire clk
        .data(display_data),        // input wire [15 : 0] data
        .sm_wei(sm_wei),    // output wire [3 : 0] sm_wei
        .sm_duan(sm_duan)  // output wire [6 : 0] sm_duan
    );
    

    wire [31:0] result; //ALU计算

    //读取指令
    PC pc (
        .Clk(Clk),
        .Clr(Clr),
        .Branch(Branch),
        .Jump(Jump),
        .inst(inst),
        .PC(PC),
        .result(result),
        .over(over),
        .IF(IF),
        .sortover(sortover)
    );

    InstMem instMem (
        .addra(PC),
        .douta(inst)
    );

    //控制单元
    AluCtrl aluCtrl (
        .inst(inst),
        .ID(ID),
        .AluCtrl(AluCtrl),
        .Reg_Dst(Reg_Dst),
        .ALU_Src1(ALU_Src1),
        .ALU_Src2(ALU_Src2),
        .Mem_Write(Mem_Write),
        .Mem_Read(Mem_Read),
        .MemtoReg(MemtoReg),
        .Reg_Write(Reg_Write),
        .Branch(Branch),
        .Jump(Jump),
        .Halt(Halt),
        .stage(stage)
    );

    //写入和读取寄存器的数据
    reg [31:0] Write_Reg_Data;
    wire [31:0] Read_Reg_Data1;
    wire [31:0] Read_Reg_Data2;

    //数据流读取rs和rt的数据
    assign Read_Reg_Addr1 = inst[25:21];
    assign Read_Reg_Addr2 = inst[20:16];

    RegFile regFile (
        .Clk(Clk),
        .Clr(Clr),
        .Reg_Write(Reg_Write),
        .Read_Reg_Addr1(Read_Reg_Addr1),
        .Read_Reg_Addr2(Read_Reg_Addr2),
        .Write_Reg_Addr(Write_Reg_Addr),
        .Write_Reg_Data(Write_Reg_Data),
        .Read_Reg_Data1(Read_Reg_Data1),
        .Read_Reg_Data2(Read_Reg_Data2)
    );

    //输入ALU的数据
    reg [31:0] input1;
    reg [31:0] input2;
    
    // 决定ALU的输入
    always @* begin
        if (Mem_Read == 1 || Mem_Write == 1) begin //lw、sw指令//lw、sw的立即数直接设置为0（lw $rt,0($rs)）即result为0-9
            input1 = Read_Reg_Data1;
        end else if (ALU_Src1 == 1) begin //sll指令
            input1 = Read_Reg_Data2;
        end else begin
            input1 = Read_Reg_Data1;
        end
        if (Mem_Read == 1 || Mem_Write == 1) begin
            input2 = 32'b0; //lw、sw的立即数直接设置为0-9（lw $rt,0(0-9)）input1为0，即result为0-9
        end if (ALU_Src2 == 1) begin //ALU_Src2为1，则第二个输入为立即数
            input2 = {{16{inst[15]}}, inst[15:0]};
        end else if (ALU_Src1 == 1) begin //sll指令
            input2 = inst[15:11];  //shamt
        end else begin
            input2 = Read_Reg_Data2;
        end
    end

    wire zero;
    //wire [31:0] result; //ALU计算

    ALU alu (
        .input1(input1),
        .input2(input2),
        .AluCtrl(AluCtrl),
        .EX(EX),
        .result(result),
        .zero(zero)
    );

    reg [31:0] Mem_write_data2;
    //lw、sw的立即数直接设置为0（lw $rt,0($rs)）即result为0-9
    always @* begin
        //准备读取和写入内存的数据和地址，MEM阶段在DataMem实现
        if (Mem_Read == 1 || Mem_Write == 1) begin
            Mem_write_addr = result; //Mem_Write为1直接写入数据存储器
            Mem_read_addr = result; //数据流直接读取数据到Mem_read_data
            Mem_write_data2 = Read_Reg_Data2; //Mem_Write为1直接写入数据存储器
        end

        //写回(WriteBack阶段)
        if (WB == 1) begin
            if (Reg_Dst == 1) begin //R型指令
                Write_Reg_Addr = inst[15:11]; //R型指令的rd
                Write_Reg_Data = result;
            end else begin
                Write_Reg_Addr = inst[20:16]; //lw、sw指令的rt
                // Write_Reg_Data = result;
                if (MemtoReg == 1) begin
                    Write_Reg_Data = Mem_read_data;
                end else begin
                    Write_Reg_Data = result;
                end
            end      
        end
    end


    // 读取内存的数据
    integer i = 0;
    reg [9:0] display_led2;
    reg [31:0] Mem_read_addr2;
    always @(posedge clk_div or posedge Clr) begin
        if (Clr == 1) begin
            display_led2 = 10'b1000000000;
            i = 0;
        end else if (sortover == 1) begin
            if (i < 10) begin
                case (i)
                    0: display_led2 = 10'b1000000000;
                    1: display_led2 = 10'b0100000000;
                    2: display_led2 = 10'b0010000000;
                    3: display_led2 = 10'b0001000000;
                    4: display_led2 = 10'b0000100000;
                    5: display_led2 = 10'b0000010000;
                    6: display_led2 = 10'b0000001000;
                    7: display_led2 = 10'b0000000100;
                    8: display_led2 = 10'b0000000010;
                    9: display_led2 = 10'b0000000001;
                endcase
                Mem_read_addr2 = i;
                i = i + 1;
            end else begin
                i = 0;
            end
        end
    end

    always @* begin
        display_led3 = sortover ? display_led2 : display_led;
        Mem_read_addr3 = sortover ? Mem_read_addr2 : Mem_read_addr;
        Mem_write_data3 = over ? Mem_write_data2 : Mem_write_data;
    end

endmodule
