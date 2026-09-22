`timescale 1ns/1ps

module reg_file_tb;

    reg        clk;
    reg        we;
    reg  [1:0] waddr;
    reg  [7:0] wdata;
    reg  [1:0] raddr1;
    reg  [1:0] raddr2;
    wire [7:0] rdata1;
    wire [7:0] rdata2;

    // instantiate the design under test (DUT)
    reg_file dut (
        .clk(clk),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // generate a clock: toggle every 5ns -> 10ns period
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0, reg_file_tb);

        // init
        clk = 0;
        we = 0;
        waddr = 0; wdata = 0;
        raddr1 = 0; raddr2 = 0;

        // Test 1: write 8'hA5 into register 2
        @(negedge clk);
        we = 1; waddr = 2; wdata = 8'hA5;
        @(posedge clk);   // write happens here
        #1;
        we = 0;

        // Test 2: read it back on port 1
        raddr1 = 2;
        #1;
        if (rdata1 !== 8'hA5) begin
            $display("FAIL: expected reg2=A5, got %h", rdata1);
            errors = errors + 1;
        end else begin
            $display("PASS: reg2 read A5 correctly");
        end

        // Test 3: write different value to register 0, check both ports independently
        @(negedge clk);
        we = 1; waddr = 0; wdata = 8'h3C;
        @(posedge clk);
        #1;
        we = 0;

        raddr1 = 0; raddr2 = 2;
        #1;
        if (rdata1 !== 8'h3C || rdata2 !== 8'hA5) begin
            $display("FAIL: port1=%h port2=%h, expected 3C and A5", rdata1, rdata2);
            errors = errors + 1;
        end else begin
            $display("PASS: both read ports correct simultaneously");
        end

        // Test 4: write disabled - value should NOT change
        @(negedge clk);
        wdata = 8'hFF;  // we is 0, this should be ignored
        @(posedge clk);
        #1;
        raddr1 = 0;
        #1;
        if (rdata1 !== 8'h3C) begin
            $display("FAIL: write-disabled register changed! got %h", rdata1);
            errors = errors + 1;
        end else begin
            $display("PASS: write enable correctly gated the write");
        end

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule