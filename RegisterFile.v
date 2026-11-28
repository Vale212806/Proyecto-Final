module RegisterFile(
    input clk,
    input RegWrite,
    input [4:0] ReadReg1,
    input [4:0] ReadReg2,
    input [4:0] WriteReg,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'd0;

        // Valores iniciales del banco de registros
        regs[8]  = 32'd125; // $t0
        regs[9]  = 32'd25;  // $t1
        regs[10] = 32'd220; // $t2
        regs[11] = 32'd96;  // $t3
        regs[12] = 32'd950; // $t4
        regs[13] = 32'd23;  // $t5
        regs[14] = 32'd20;  // $t6
        regs[15] = 32'd20;  // $t7
        regs[16] = 32'd24;  // $s0
        regs[17] = 32'd28;  // $s1
    end

    // Lectura combinacional ($0 siempre devuelve 0)
    assign ReadData1 = (ReadReg1 == 5'd0) ? 32'd0 : regs[ReadReg1];
    assign ReadData2 = (ReadReg2 == 5'd0) ? 32'd0 : regs[ReadReg2];

    // Escritura sincrona protegiendo $0 ($zero)
    always @(posedge clk) begin
        if (RegWrite && (WriteReg != 5'd0))
            regs[WriteReg] <= WriteData;
    end
endmodule
