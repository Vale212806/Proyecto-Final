module ALU(
    input [31:0] A, B,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output Zero, GreaterZero
);
    always @(*) begin
        case(ALUControl)
            4'b0010: Result = A + B;
            4'b0110: Result = A - B;
            4'b0000: Result = A & B;
            4'b0001: Result = A | B;
            4'b0111: Result = ($signed(A) < $signed(B)) ? 1 : 0;
            4'b1100: Result = ($signed(A) > 0) ? 1 : 0;
            default: Result = 0;
        endcase
    end
    assign Zero = (Result == 0);
    assign GreaterZero = ($signed(A) > 0);
endmodule
