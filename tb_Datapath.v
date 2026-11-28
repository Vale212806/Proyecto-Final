`timescale 1ns/1ps
module tb_Datapath;
    reg clk;
    reg reset;

    DatapathCompleto dut(
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        #180; // Ejecuta los 17 ciclos activos (PC=0 hasta PC=76)


        $display("1.  add  $t2 = %0d (esp: 150)           -> %s", dut.rf.regs[10], (dut.rf.regs[10] == 32'd150) ? "PASS" : "FAIL");
        $display("2.  sub  $t3 = %0d (esp: 100)           -> %s", dut.rf.regs[11], (dut.rf.regs[11] == 32'd100) ? "PASS" : "FAIL");
        $display("3.  and  $t4 = %0d (esp: 25)            -> %s", dut.rf.regs[12], (dut.rf.regs[12] == 32'd25)  ? "PASS" : "FAIL");
        $display("4.  or   $t5 = %0d (esp: 125)           -> %s", dut.rf.regs[13], (dut.rf.regs[13] == 32'd125) ? "PASS" : "FAIL");
        $display("5.  slt(T) $s0 = %0d (esp: 1)           -> %s", dut.rf.regs[16], (dut.rf.regs[16] == 32'd1)   ? "PASS" : "FAIL");
        $display("6.  slt(F) $s1 = %0d (esp: 0)           -> %s", dut.rf.regs[17], (dut.rf.regs[17] == 32'd0)   ? "PASS" : "FAIL");
        $display("7.  addi(neg) $s2 = %0d (esp: 20)       -> %s", $signed(dut.rf.regs[18]), ($signed(dut.rf.regs[18]) == 20) ? "PASS" : "FAIL");
        $display("8.  slti(neg) $s3 = %0d (esp: 0)        -> %s", dut.rf.regs[19], (dut.rf.regs[19] == 32'd0)   ? "PASS" : "FAIL");
        $display("9.  ori(bit15=1) $s4 = 0x%h             -> %s", dut.rf.regs[20], (dut.rf.regs[20] == 32'h00008001) ? "PASS" : "FAIL");
        $display("10. andi(bit15=1) $s5 = 0x%h            -> %s", dut.rf.regs[21], (dut.rf.regs[21] == 32'h00008001) ? "PASS" : "FAIL");
        $display("11. Proteccion $zero = %0d (esp: 0)     -> %s", dut.rf.regs[0],  (dut.rf.regs[0]  == 32'd0)   ? "PASS" : "FAIL");
        $display("12. lw   $s6 = %0d (esp: 500)           -> %s", dut.rf.regs[22], (dut.rf.regs[22] == 32'd500) ? "PASS" : "FAIL");
        $display("13. sw   Mem[7] = %0d (esp: 125)        -> %s", dut.DataMem[7],  (dut.DataMem[7]  == 32'd125) ? "PASS" : "FAIL");
        $display("14. beq/j saltos ($s7) = %0d (esp: 0)   -> %s", dut.rf.regs[23], (dut.rf.regs[23] == 32'd0)   ? "PASS" : "FAIL");
        $display("15. Destino jump ($t8) = %0d (esp: 150) -> %s", dut.rf.regs[24], (dut.rf.regs[24] == 32'd150) ? "PASS" : "FAIL");
        $finish;
    end

    always #5 clk = ~clk;
endmodule
