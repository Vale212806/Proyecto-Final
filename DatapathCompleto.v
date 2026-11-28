module DatapathCompleto(
    input clk,
    input reset
);
    reg [31:0] PC;
    wire [31:0] PCPlus4, PCBranch, PCJump, PCNext;
    wire [31:0] Instr;
    wire [31:0] ReadData1, ReadData2, WriteData, ALUResult, MemReadData;
    wire [31:0] SignExtImm, ZeroExtImm, ExtImm, ALUSrcB;
    wire [4:0] WriteReg;
    wire [3:0] ALUControlSig;
    wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump, ZeroExt, Zero;
    wire [1:0] ALUOp;
    wire PCSrc;

    // Memorias indexadas por palabra (byte_addr / 4 -> bits [7:2])
    reg [31:0] InstrMem [0:63];
    reg [31:0] DataMem  [0:63];
    integer k;

    initial begin
        for (k = 0; k < 64; k = k + 1) begin
            InstrMem[k] = 32'd0;
            DataMem[k]  = 32'd0;
        end

        // Precarga de Memoria de Datos (alineada a 4 bytes)
        DataMem[5] = 32'd500; // Direccion de byte 20 -> palabra 5
        DataMem[7] = 32'd609; // Direccion de byte 28 -> palabra 7


        // 0  (PC=0):  add  $t2, $t0, $t1      -> 125 + 25 = 150
        InstrMem[0]  = 32'h01095020;
        // 1  (PC=4):  sub  $t3, $t0, $t1      -> 125 - 25 = 100
        InstrMem[1]  = 32'h01095822;
        // 2  (PC=8):  and  $t4, $t0, $t1      -> 125 & 25 = 25
        InstrMem[2]  = 32'h01096024;
        // 3  (PC=12): or   $t5, $t0, $t1      -> 125 | 25 = 125
        InstrMem[3]  = 32'h01096825;
        // 4  (PC=16): slt  $s0, $t1, $t0      -> 25 < 125 = 1 (Verdadero)
        InstrMem[4]  = 32'h0128802A;
        // 5  (PC=20): slt  $s1, $t0, $t1      -> 125 < 25 = 0 (Falso)
        InstrMem[5]  = 32'h0109882A;
        // 6  (PC=24): addi $s2, $t1, -5       -> 25 + (-5) = 20 (Inmediato negativo)
        InstrMem[6]  = 32'h2132FFFB;
        // 7  (PC=28): slti $s3, $t1, -1       -> 25 < -1 = 0 (Falso con negativo)
        InstrMem[7]  = 32'h2933FFFF;
        // 8  (PC=32): ori  $s4, $zero, 0x8001 -> 0x00008001 (Bit 15=1, ext. ceros)
        InstrMem[8]  = 32'h34148001;
        // 9  (PC=36): andi $s5, $s4, 0x8001   -> 0x00008001 (Bit 15=1, ext. ceros)
        InstrMem[9]  = 32'h32958001;
        // 10 (PC=40): add  $zero, $t0, $t1    -> Intento escritura en $zero (= 0)
        InstrMem[10] = 32'h01090020;
        // 11 (PC=44): lw   $s6, 20($zero)     -> DataMem[20/4=5] = 500
        InstrMem[11] = 32'h8C160014;
        // 12 (PC=48): sw   $t0, 28($zero)     -> DataMem[28/4=7] = 125
        InstrMem[12] = 32'hAC08001C;
        // 13 (PC=52): beq  $t0, $t1, 1        -> 125 == 25 (Falso, NO tomado -> PC=56)
        InstrMem[13] = 32'h11090001;
        // 14 (PC=56): beq  $t6, $t7, 1        -> 20 == 20 (Verdadero, TOMADO -> PC=64)
        InstrMem[14] = 32'h11CF0001;
        // 15 (PC=60): addi $s7, $zero, 99     -> Instruccion saltada por beq
        InstrMem[15] = 32'h20170063;
        // 16 (PC=64): j    18                 -> Salto incondicional a palabra 18 (PC=72)
        InstrMem[16] = 32'h08000012;
        // 17 (PC=68): addi $s7, $zero, 88     -> Instruccion saltada por j
        InstrMem[17] = 32'h20170058;
        // 18 (PC=72): add  $t8, $t0, $t1      -> Destino de j: 125 + 25 = 150
        InstrMem[18] = 32'h0109C020;
    end

    // Instanciacion de modulos
    Control ctrl(
        .Opcode(Instr[31:26]),
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ZeroExt(ZeroExt),
        .ALUOp(ALUOp)
    );

    ALUControl aluCtrl(
        .ALUOp(ALUOp),
        .Funct(Instr[5:0]),
        .Opcode(Instr[31:26]),
        .ALUControlOut(ALUControlSig)
    );

    RegisterFile rf(
        .clk(clk),
        .RegWrite(RegWrite),
        .ReadReg1(Instr[25:21]),
        .ReadReg2(Instr[20:16]),
        .WriteReg(WriteReg),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    ALU alu(
        .A(ReadData1),
        .B(ALUSrcB),
        .ALUControl(ALUControlSig),
        .Result(ALUResult),
        .Zero(Zero)
    );

    // Logica combinacional del Datapath
    assign Instr       = InstrMem[PC[7:2]];
    assign PCPlus4     = PC + 32'd4;
    assign SignExtImm  = {{16{Instr[15]}}, Instr[15:0]};
    assign ZeroExtImm  = {16'b0, Instr[15:0]};
    assign ExtImm      = ZeroExt ? ZeroExtImm : SignExtImm;
    assign ALUSrcB     = ALUSrc ? ExtImm : ReadData2;
    assign WriteReg    = RegDst ? Instr[15:11] : Instr[20:16];
    assign WriteData   = MemtoReg ? MemReadData : ALUResult;
    assign MemReadData = MemRead ? DataMem[ALUResult[7:2]] : 32'd0;
    assign PCBranch    = PCPlus4 + (SignExtImm << 2);
    assign PCJump      = {PCPlus4[31:28], Instr[25:0], 2'b00};

    assign PCSrc  = Branch & Zero;
    assign PCNext = Jump ? PCJump : (PCSrc ? PCBranch : PCPlus4);

    // Logica secuencial (PC y escritura en DataMem)
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'd0;
        else begin
            PC <= PCNext;
            if (MemWrite)
                DataMem[ALUResult[7:2]] <= ReadData2;
        end
    end
endmodule
