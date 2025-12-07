module ula(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [4:0] shamt,
    input wire [3:0] alu_control,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case (alu_control)
            4'b0010: result = a + b; // ADD
            4'b0110: result = a - b; // SUB
            4'b0000: result = a & b; // AND
            4'b0001: result = a | b; // OR
            4'b0011: result = a ^ b; // XOR
            4'b0100: result = ~(a | b); // NOR
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
            4'b1000: result = (a < b) ? 32'b1 : 32'b0; // SLTU
            4'b1001: result = b << shamt; // SLL
            4'b1010: result = b >> shamt; // SRL
            4'b1011: result = b << 16; // LUI (shift left 16)
            4'b1100: result = b << a; // SLLV
            4'b1101: result = b >> a; // SRLV
            4'b1110: result = $signed($signed(b) >>> $signed(a)); // SRAV
            4'b1111: result = $signed($signed(b) >>> shamt); // SRA
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule 