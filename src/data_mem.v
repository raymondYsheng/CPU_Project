module data_mem (
    input        clk,
    input        we,          // write enable (STORE)
    input  [2:0] addr,        // 3-bit address -> 8 words
    input  [7:0] wdata,       // data to store
    output [7:0] rdata        // data read out (for LOAD)
);
    reg [7:0] mem [0:7];

    integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1)
            mem[i] = 8'b0;    // clean slate for simulation
    end

    assign rdata = mem[addr];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end
endmodule