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
    reg [63:0] IF_ID;
    reg [127:0] ID_EX;
    reg [127:0] EX_MEM;
    reg [127:0] MEM_WB;
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
    reg Branch;
    reg Jump;
    wire Halt;
    wire write_enable_btn;
    wire [15:0] Mem_read_data; //数据存储器读出的数据
    wire [15:0] display_data; //显示的数据
    reg equal;
    reg valid;
    reg [15:0] cnt;
    //ALU输入
    reg [31:0] input1;
    reg [31:0] input2;
    wire [31:0] result; //ALU计算
    reg [31:0] Mem_write_data2;
    //输入数据
    reg [3:0] Mem_read_addr3;
    reg [15:0] Mem_write_data3;
    reg [3:0] Mem_write_addr;
    reg [3:0] Mem_read_addr;
    reg Forward_EXMEMrtTors;
    reg Forward_EXMEMrtTort;
    reg Forward_EXMEMrdTors;
    reg Forward_EXMEMrdTort;
    reg Forward_MEMWBrtTors;
    reg Forward_MEMWBrtTort;
    reg Forward_EXMEMrdTors2;
    reg Forward_EXMEMrdTort2;
    reg crash;
    initial begin
        IF_ID = 64'h0000000000000000; //[31:0]inst,[39:32]PC
        ID_EX = 127'h00000000000000000000000000000000; //[3:0]AluCtrl,{[13]Halt,[12]Jump,[11]Branch,[10]Reg_Write,[9]MemtoReg,[8]Mem_Read,[7]Mem_Write,[6]ALU_Src2,[5]ALU_Src1,[4]Reg_Dst},[16:14]stage
        EX_MEM = 127'h00000000000000000000000000000000;
        MEM_WB = 127'h00000000000000000000000000000000;
        valid = 1;
        cnt = 0;
        Mem_write_data2 = 0;
        Mem_read_addr3 = 0;
        Mem_write_data3 = 0;
        Mem_write_addr = 0;
        Mem_read_addr = 0;
        //Branch1 = 1;
        Branch = 1;
        Jump = 0;
        input1 = 0;
        input2 = 0;
        Forward_EXMEMrtTors = 0;
        Forward_EXMEMrtTort = 0;
        Forward_EXMEMrdTors = 0;
        Forward_EXMEMrdTort = 0;
        Forward_MEMWBrtTors = 0;
        Forward_MEMWBrtTort = 0;
        Forward_EXMEMrdTors2 = 0;
        Forward_EXMEMrdTort2 = 0;
        crash = 0;
    end 
    //写入和读取寄存器的数据
    reg [31:0] Write_Reg_Data;
    wire [31:0] Read_Reg_Data1;
    wire [31:0] Read_Reg_Data2;
    assign Read_Reg_Addr1 = IF_ID[25:21]/*ID_EX[42:38]*//*inst[25:21]*/;
    assign Read_Reg_Addr2 = IF_ID[20:16]/*ID_EX[37:33]*//*inst[20:16]*/;
    RegFile regFile (
        .Clk(Clk),
        .Clr(Clr),
        .Reg_Write(MEM_WB[34]),
        .Read_Reg_Addr1(Read_Reg_Addr1),
        .Read_Reg_Addr2(Read_Reg_Addr2),
        .Write_Reg_Addr(Write_Reg_Addr),
        .Write_Reg_Data(Write_Reg_Data),
        .Read_Reg_Data1(Read_Reg_Data1),
        .Read_Reg_Data2(Read_Reg_Data2)
    );
    always @(posedge Clk or negedge Clk) begin
        if (over==1&&sortover==0) begin
            cnt = cnt + 1;
            if (!Clk) begin
                Mem_read_addr = EX_MEM[63:32]/*result*/; //数据流直接读取数据到Mem_read_data
                //控制冒险
                equal = (Read_Reg_Data1 == Read_Reg_Data2);
                Jump = (IF_ID[31:26] == 6'b000010);
                //lw数据冒险
                crash = (IF_ID[31:26] == 6'b100011 && (IF_ID[20:16] == inst[25:21] || IF_ID[20:16] == inst[20:16]));
                valid = !(/*Branch1 || */Jump) && !crash;  //插入nop
            end
            if (Clk) begin
                //写入MEM_WB
                MEM_WB[31:0] = Mem_read_data; //先写后读
                MEM_WB[32] = EX_MEM[0]/*Reg_Dst*/;
                MEM_WB[33] = EX_MEM[3]/*MemtoReg*/;
                MEM_WB[34] = EX_MEM[4]/*Reg_Write*/;
                MEM_WB[35] = EX_MEM[5]/*Halt*/;
                MEM_WB[45:36] = EX_MEM[15:6];//rt,rd
                MEM_WB[95:64] = EX_MEM[63:32]/*result*/;
                //写入EX_MEM
                EX_MEM[0] = ID_EX[4]/*Reg_Dst*/;
                EX_MEM[1] = ID_EX[7]/*Mem_Write*/;///////////////!!!!!!!!!!!!!!!!是否冲突
                EX_MEM[2] = ID_EX[8]/*Mem_Read*/;
                EX_MEM[3] = ID_EX[9]/*MemtoReg*/;
                EX_MEM[4] = ID_EX[10]/*Reg_Write*/;
                //end
                EX_MEM[5] = ID_EX[13]/*Halt*/;
                //EX_MEM[6] = ID_EX[43]/*valid*/;
                //EX_MEM[63:32] = result;
                EX_MEM[15:6] = ID_EX[37:28];//rt,rd
                //EX阶段读取ID_EX,RegFile输入也为ID_EX,结果写入EX_MEM
                EX_MEM[63:32] = result;
                EX_MEM[95:64] = ID_EX[127:96]; //sw指令的rt
                //写入ID_EX
                ID_EX[3:0] = AluCtrl;
                ID_EX[4] = Reg_Dst;
                ID_EX[5] = ALU_Src1;
                ID_EX[6] = ALU_Src2;
                if (Branch) begin
                    ID_EX[7] = 0;
                    ID_EX[8] = 0;
                    ID_EX[9] = 0;
                    ID_EX[10] = 0;
                end else begin
                    ID_EX[7] = Mem_Write;
                    ID_EX[8] = Mem_Read;
                    ID_EX[9] = MemtoReg;
                    ID_EX[10] = Reg_Write;
                end
                //ID_EX[11] = Branch;
                //ID_EX[12] = Jump;
                ID_EX[13] = Halt;
                //ID_EX[16:14] = stage;
                //ID_EX[36:17] = IF_ID[25:6];
                ID_EX[48:17] = IF_ID[31:0];
                ID_EX[95:64] = Read_Reg_Data1;
                ID_EX[127:96] = Read_Reg_Data2;
                //写入IF_ID
                if (!valid || Branch) begin
                    IF_ID[31:0] = 8'h00000000;
                end else begin
                    IF_ID[31:0] = inst;
                end
            end
        end
    end
    always @* begin
        if (over==1&&sortover==0) begin
            Forward_EXMEMrtTors = (!EX_MEM[0] && EX_MEM[4] && (EX_MEM[15:11] == ID_EX[42:38]));
            Forward_EXMEMrtTort = (!EX_MEM[0] && EX_MEM[4] && (EX_MEM[15:11] == ID_EX[37:33]));
            Forward_EXMEMrdTors = (EX_MEM[0] && EX_MEM[4] && (EX_MEM[10:6] == ID_EX[42:38]));
            Forward_EXMEMrdTort = (EX_MEM[0] && EX_MEM[4] && (EX_MEM[10:6] == ID_EX[37:33]));
            Forward_EXMEMrdTors2 = (MEM_WB[32] && MEM_WB[32] && MEM_WB[40:36] == ID_EX[42:38]);
            Forward_EXMEMrdTort2 = (MEM_WB[32] && MEM_WB[32] && MEM_WB[40:36] == ID_EX[37:33]);
            Forward_MEMWBrtTors = (MEM_WB[33] && MEM_WB[34] && (MEM_WB[45:41] == ID_EX[42:38]));//
            Forward_MEMWBrtTort = (MEM_WB[33] && MEM_WB[34] && (MEM_WB[45:41] == ID_EX[37:33]));//
            Branch = (ID_EX[48:43] == 6'b000100 && result == 0) || (ID_EX[48:43] == 6'b000101 && result != 0);   
            //EX准备ALU的输入
            if (Forward_EXMEMrtTors || Forward_EXMEMrdTors) begin
                input1 = EX_MEM[63:32]/*result*/;
            end else if (Forward_MEMWBrtTors) begin
                input1 = MEM_WB[31:0];
            end else if (Forward_EXMEMrdTors2) begin
                input1 = MEM_WB[95:64];
            end else begin
                if (ID_EX[8]/*Mem_Read*/ == 1 || ID_EX[7]/*Mem_Write*/ == 1) begin //lw、sw指令//lw、sw的立即数直接设置为0（lw $rt,0($rs)）即result为0-9
                    input1 = ID_EX[95:64]/*Read_Reg_Data1*/;
                end else if (ID_EX[5]/*ALU_Src1*/ == 1) begin //sll指令
                    input1 = ID_EX[127:96]/*Read_Reg_Data2*/;
                end else begin
                    input1 = ID_EX[95:64]/*Read_Reg_Data1*/;
                end
            end
            if (Forward_EXMEMrtTort || Forward_EXMEMrdTort) begin
                input2 = EX_MEM[63:32]/*result*/;
            end else if (Forward_MEMWBrtTort) begin
                input2 = MEM_WB[31:0];
            end else if (Forward_EXMEMrdTort2) begin
                input2 = MEM_WB[95:64];
            end else begin
                if (ID_EX[8]/*Mem_Read*/ == 1 || ID_EX[7]/*Mem_Write*/ == 1) begin
                    input2 = 32'b0; //lw、sw的立即数直接设置为0-9（lw $rt,0(0-9)）input1为0，即result为0-9
                end if (ID_EX[6]/*ALU_Src2*/ == 1) begin //ALU_Src2为1，则第二个输入为立即数
                    input2 = {{16{ID_EX[32]/*inst[15]*/}}, ID_EX[32:17]/*inst[15:0]*/};
                end else if (ID_EX[5]/*ALU_Src1*/ == 1) begin //sll指令
                    input2 = ID_EX[32:28]/*inst[15:11]*/;  //shamt
                end else begin
                    input2 = ID_EX[127:96]/*Read_Reg_Data2*/;
                end
            end
            //MEM准备写入存储器
            Mem_write_addr = EX_MEM[63:32]; //Mem_Write为1直接写入数据存储器
            Mem_write_data2 = EX_MEM[95:64]; //Mem_Write为1直接写入数据存储器
            //WB准备写回寄存器的数据，写回冲突
            if (MEM_WB[32]/*Reg_Dst*/ == 1) begin //R型指令
                Write_Reg_Addr = MEM_WB[40:36]/*inst[15:11]*/; //R型指令的rd
                Write_Reg_Data = MEM_WB[95:64]/*result*/;
            end else begin
                Write_Reg_Addr = MEM_WB[45:41]/*inst[20:16]*/; //lw、sw指令的rt
                // Write_Reg_Data = result;
                if (MEM_WB[33]/*MemtoReg*/ == 1) begin //lw
                    Write_Reg_Data = MEM_WB[31:0]/*Mem_read_data*/;
                end else begin //I型算术指令
                    Write_Reg_Data = MEM_WB[95:64]/*result*/;
                end
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
    DataMem dataMem (
        .clk(Clk),
        .clr(Clr),
        //.write_enable_btn(write_enable_btn),
        .write_enable_btn(btn_in),
        .Mem_Write(EX_MEM[1]/*Mem_Write*/),
        .Mem_write_data(Mem_write_data3),
        .Mem_write_addr(Mem_write_addr),
        .Mem_read_addr(Mem_read_addr3),
        .Mem_read_data(Mem_read_data),
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
    //读取指令
    PC pc (
        .Clk(Clk),
        .Clr(Clr),
        //.Branch1(Branch1),
        .Branch(Branch),
        .Jump(Jump),
        .crash(crash),
        .inst1(IF_ID[31:0]),
        .inst2(ID_EX[35:17]),
        .PC(PC),
        //.result(result),
        .over(over),
        .sortover(sortover)
    );
    InstMem instMem (
        .addra(PC),
        .douta(inst)
    );
    //控制单元
    AluCtrl aluCtrl (
        .Clk(Clk),
        .inst(IF_ID[31:0]),
        .AluCtrl(AluCtrl),
        .Reg_Dst(Reg_Dst),
        .ALU_Src1(ALU_Src1),
        .ALU_Src2(ALU_Src2),
        .Mem_Write(Mem_Write),
        .Mem_Read(Mem_Read),
        .MemtoReg(MemtoReg),
        .Reg_Write(Reg_Write),
        //.Branch(Branch),
        //.Jump(Jump),
        .Halt(Halt)
        //.stage(stage)
    );
    wire zero;
    ALU alu (
        .Clk(Clk),
        .input1(input1),
        .input2(input2),
        .AluCtrl(ID_EX[3:0]),
        .result(result),
        .zero(zero)
    );
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
