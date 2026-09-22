module alu (
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] op,      // 00=ADD 01=SUB 10=AND 11=OR
    output reg [7:0] result,
    output       zero
);
    always @(*) begin
        case (op)
            2'b00: result = a + b; // ADD
            2'b01: result = a - b; // SUB
            2'b10: result = a & b; // AND
            2'b11: result = a | b; // OR
            default: result = 8'h00;
        endcase
    end

    assign zero = (result == 8'b0);

endmodule