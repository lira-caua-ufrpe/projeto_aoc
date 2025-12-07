module ula_ctrl(
    input wire [4:0] alu_op,
    input wire [5:0] funct,
    output reg [3:0] alu_control
);
    always @(*) begin
        case (alu_op)
            5'b00000: alu_control = 4'b0010; // LW, SW: ADD
            5'b00001: alu_control = 4'b0110; // BEQ: SUB
            5'b00010: begin // R-type
                case (funct)
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b100110: alu_control = 4'b0011; // XOR
                    6'b100111: alu_control = 4'b0100; // NOR
                    6'b101010: alu_control = 4'b0111; // SLT
                    6'b101011: alu_control = 4'b1000; // SLTU
                    6'b000000: alu_control = 4'b1001; // SLL
                    6'b000010: alu_control = 4'b1010; // SRL
                    6'b000011: alu_control = 4'b1111; // SRA
                    6'b000100: alu_control = 4'b1100; // SLLV
                    6'b000110: alu_control = 4'b1101; // SRLV
                    6'b000111: alu_control = 4'b1110; // SRAV
                    6'b001000: alu_control = 4'b1110; // JR
                    default:   alu_control = 4'b0000;
                endcase
            end
            5'b00011: alu_control = 4'b0111; // SLTI
            5'b01000: alu_control = 4'b1000; // SLTIU
            5'b00100: alu_control = 4'b0000; // ANDI
            5'b00101: alu_control = 4'b0001; // ORI
            5'b00110: alu_control = 4'b1101; // XORI
            5'b00111: alu_control = 4'b1011; // LUI (shift left 16)
            default: alu_control = 4'b0000;
        endcase
    end
endmodule 