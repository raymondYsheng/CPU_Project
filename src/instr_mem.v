module instr_mem (
    input      [2:0] pc,        // 3-bit address -> 8 words
    output     [7:0] instr
);
    reg [7:0] mem [0:7];

    // Loads program.hex at simulation start. One 2-digit hex byte per
    // line, e.g. "80" for LOAD r0, mem[0].
    initial begin
        $readmemh("src/program.hex", mem);
    end

    assign instr = mem[pc];
endmodule