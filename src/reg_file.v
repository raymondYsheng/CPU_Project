module reg_file (
    input  wire       clk,
    input  wire        we,       // write enable
    input  wire [1:0]  waddr,    // write address
    input  wire [7:0]  wdata,    // write data
    input  wire [1:0]  raddr1,   // read port 1 address
    input  wire [1:0]  raddr2,   // read port 2 address
    output wire [7:0]  rdata1,   // read port 1 data
    output wire [7:0]  rdata2    // read port 2 data
);
    reg [7:0] regs [0:3];
    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];

    // clocked write
    always @(posedge clk) begin
        if (we)
            regs[waddr] <= wdata;
    end

endmodule