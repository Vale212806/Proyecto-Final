module ALUControl(
    input [1:0] ALUOp,
    input [5:0] Funct,
    input [5:0] Opcode,
    output reg [3:0] ALUControlOut
);
    always @(*) begin
        case(ALUOp)
            2'b00: ALUControlOut = 4'b0010; // lw, sw, addi
            2'b01: ALUControlOut = 4'b0110; // beq, bne
            2'b11: ALUControlOut = 4'b1100; // bgtz
            2'b10: begin // Tipo R
                case(Funct)
                    6'b100000: ALUControlOut = 4'b0010; // add
                    6'b101010: ALUControlOut = 4'b0111; // slt
                    6'b100010: ALUControlOut = 4'b0110; // sub
                    6'b100100: ALUControlOut = 4'b0000; // and
                    6'b100101: ALUControlOut = 4'b0001; // or
                    default: ALUControlOut = 4'b0010;
                endcase
            end
            default: ALUControlOut = 4'b0010;
        endcase
        if(Opcode == 6'b001010) ALUControlOut = 4'b0111; // slti
    end
endmodule
