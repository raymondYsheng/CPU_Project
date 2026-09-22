module control_unit (
    input      [2:0] opcode,      // instr[7:5]
    output reg       reg_write,   // write result into rd
    output reg       mem_read,    // LOAD: read data_mem
    output reg       mem_write,   // STORE: write data_mem
    output reg       branch,      // BEQ
    output reg       jump,        // JUMP
    output reg       mem_to_reg,  // 1 = writeback comes from data_mem, 0 = from ALU
    output     [1:0] alu_op       // only meaningful for ADD/SUB/AND/OR
);
    // ADD/SUB/AND/OR opcodes are 000/001/010/011, so the low 2 bits
    // of the opcode ARE the ALU select -- no separate decode needed.
    assign alu_op = opcode[1:0];

    always @(*) begin
        // safe defaults
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            3'b000, 3'b001, 3'b010, 3'b011: begin // ADD SUB AND OR
                reg_write  = 1'b1;
                mem_to_reg = 1'b0;
            end
            3'b100: begin // LOAD
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
            end
            3'b101: begin // STORE
                mem_write  = 1'b1;
            end
            3'b110: begin // BEQ
                branch     = 1'b1;
            end
            3'b111: begin // JUMP
                jump       = 1'b1;
            end
            default: ; // all signals stay at safe defaults
        endcase
    end
endmodule