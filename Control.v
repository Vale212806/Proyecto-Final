module Control(
    input [5:0] Opcode,
    output reg RegDst,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Jump,
    output reg ZeroExt,
    output reg [1:0] ALUOp
);
    always @(*) begin
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        ZeroExt  = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            6'b000000: begin // Tipo R: add, sub, slt, and, or
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            6'b100011: begin // lw
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b101011: begin // sw
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b000100: begin // beq
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            6'b001000: begin // addi (extension de signo)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b001010: begin // slti (extension de signo)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end
            6'b001100: begin // andi (extension con ceros)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ZeroExt  = 1'b1;
                ALUOp    = 2'b11;
            end
            6'b001101: begin // ori (extension con ceros)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ZeroExt  = 1'b1;
                ALUOp    = 2'b11;
            end
            6'b000010: begin // j
                Jump     = 1'b1;
            end
            default: begin
                // Valores por defecto en 0
            end
        endcase
    end
endmodule
