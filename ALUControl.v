module ALUControl(
    input [1:0] ALUOp,
    input [5:0] Funct,
    input [5:0] Opcode,
    output reg [3:0] ALUControlOut
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControlOut = 4'b0010; // lw, sw, addi -> Suma
            2'b01: ALUControlOut = 4'b0110; // beq -> Resta
            2'b10: begin // Tipo R (decodifica)
                case (Funct)
                    6'b100000: ALUControlOut = 4'b0010; // add
                    6'b100010: ALUControlOut = 4'b0110; // sub
                    6'b100100: ALUControlOut = 4'b0000; // and
                    6'b100101: ALUControlOut = 4'b0001; // or
                    6'b101010: ALUControlOut = 4'b0111; // slt
                    default:   ALUControlOut = 4'b0010;
                endcase
            end
            2'b11: begin // Tipo I logicas y slti (decodifica por Opcode)
                case (Opcode)
                    6'b001010: ALUControlOut = 4'b0111; // slti
                    6'b001100: ALUControlOut = 4'b0000; // andi
                    6'b001101: ALUControlOut = 4'b0001; // ori
                    default:   ALUControlOut = 4'b0010;
                endcase
            end
            default: ALUControlOut = 4'b0010;
        endcase
    end
endmodule
