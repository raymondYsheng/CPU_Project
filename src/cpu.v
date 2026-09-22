module cpu (
    input clk,
    input rst
);
    // ---- Program Counter ----
    reg [2:0] pc;

    // ---- Fetch ----
    wire [7:0] instr;
    instr_mem imem (.pc(pc), .instr(instr));

    wire [2:0] opcode = instr[7:5];

    // ---- Instruction field decode ----
    // R-type (ADD/SUB/AND/OR): rd=instr[4:3], rs=instr[2:1]
    // LOAD/STORE:              rd=instr[4:3], addr=instr[2:0]
    // BEQ:                     rs=instr[4:3] (tested reg), addr=instr[2:0]
    // JUMP:                    addr=instr[2:0] (low 3 bits of the 5-bit field --
    //                          top 2 bits unused since our program memory is 8 words)
    wire [1:0] rd_addr = instr[4:3];
    wire [1:0] rs_addr = instr[2:1];   // only meaningful for R-type
    wire [2:0] mem_addr = instr[2:0];  // LOAD/STORE/BEQ/JUMP target address

    // ---- Control unit ----
    wire reg_write, mem_read, mem_write, branch, jump, mem_to_reg;
    wire [1:0] alu_op;
    control_unit cu (
        .opcode(opcode),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .jump(jump), .mem_to_reg(mem_to_reg), .alu_op(alu_op)
    );

    // ---- Register file ----
    // rd_addr doubles as: R-type dest, LOAD dest, STORE source, BEQ tested reg
    wire [7:0] rd_data, rs_data;
    wire [7:0] write_data;
    reg_file rf (
        .clk(clk), .we(reg_write),
        .waddr(rd_addr), .wdata(write_data),
        .raddr1(rd_addr), .raddr2(rs_addr),
        .rdata1(rd_data), .rdata2(rs_data)
    );

    // ---- ALU ----
    wire [7:0] alu_result;
    wire alu_zero;
    alu ex (.a(rd_data), .b(rs_data), .op(alu_op), .result(alu_result), .zero(alu_zero));

    // ---- Data memory ----
    wire [7:0] mem_rdata;
    data_mem dmem (
        .clk(clk), .we(mem_write),
        .addr(mem_addr), .wdata(rd_data),   // STORE writes rd's value
        .rdata(mem_rdata)
    );

    // ---- Write-back mux ----
    assign write_data = mem_to_reg ? mem_rdata : alu_result;

    // ---- Branch decision ----
    // BEQ compares the tested register (rd_data, addressed via instr[4:3]) to zero
    wire beq_taken = branch && (rd_data == 8'b0);

    // ---- PC update ----
    always @(posedge clk) begin
        if (rst)
            pc <= 3'b0;
        else if (jump)
            pc <= mem_addr;
        else if (beq_taken)
            pc <= mem_addr;
        else
            pc <= pc + 3'b1;
    end
endmodule