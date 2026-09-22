`timescale 1ns/1ps

module cpu_tb;
    reg clk, rst;
    integer errors;

    cpu uut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        errors = 0;
        clk = 0;
        rst = 1;

        // let data_mem's own zero-init settle, then preload test values
        #2;
        uut.dmem.mem[0] = 8'd5;   // operand A
        uut.dmem.mem[1] = 8'd7;   // operand B

        // hold reset through one clock edge so PC starts at 0
        #10;
        rst = 0;

        // run enough cycles: LOAD, LOAD, ADD, STORE, then it jumps to
        // itself forever, so 6 cycles is plenty
        #60;

        $display("r0 = %0d", uut.rf.regs[0]);
        $display("r1 = %0d", uut.rf.regs[1]);
        $display("mem[2] = %0d", uut.dmem.mem[2]);
        $display("final PC = %0d", uut.pc);

        if (uut.rf.regs[0] == 8'd12)
            $display("PASS: r0 holds 5+7=12");
        else begin
            $display("FAIL: r0 = %0d (expected 12)", uut.rf.regs[0]);
            errors = errors + 1;
        end

        if (uut.dmem.mem[2] == 8'd12)
            $display("PASS: mem[2] holds 12 (STORE worked)");
        else begin
            $display("FAIL: mem[2] = %0d (expected 12)", uut.dmem.mem[2]);
            errors = errors + 1;
        end

        if (uut.pc == 3'd4)
            $display("PASS: PC parked at 4 (halt loop via JUMP)");
        else begin
            $display("FAIL: PC = %0d (expected 4)", uut.pc);
            errors = errors + 1;
        end

        if (errors == 0) $display("ALL CPU TESTS PASSED");
        else $display("%0d CPU TEST(S) FAILED", errors);

        $finish;
    end
endmodule