module ctrl(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output reg reg_dst,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg branch_beq,
    output reg branch_bne,
    output reg [4:0] alu_op
);
    always @(*) begin
        // Inicialização dos sinais
        reg_dst = 0;
        alu_src = 0;
        mem_to_reg = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        branch_beq = 0;
        branch_bne = 0;
        alu_op = 5'b00000;
        case (opcode)
            6'b000000: begin // R-type
                if (funct == 6'b001000) begin // JR
                    reg_dst = 0;
                    alu_src = 0;
                    mem_to_reg = 0;
                    reg_write = 0;
                    mem_read = 0;
                    mem_write = 0;
                    branch = 0;
                    branch_beq = 0;
                    branch_bne = 0;
                    alu_op = 5'b00010;
                end else begin
                    reg_dst = 1;
                    alu_src = 0;
                    mem_to_reg = 0;
                    reg_write = 1;
                    mem_read = 0;
                    mem_write = 0;
                    branch = 0;
                    branch_beq = 0;
                    branch_bne = 0;
                    alu_op = 5'b00010;
                end
            end
            6'b100011: begin // LW
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 1;
                reg_write = 1;
                mem_read = 1;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000;
            end
            6'b101011: begin // SW
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 1;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000;
            end
            6'b000100: begin // BEQ
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 1;
                branch_beq = 1;
                branch_bne = 0;
                alu_op = 5'b00001;
            end
            6'b000101: begin // BNE
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 1;
                alu_op = 5'b00001;
            end
            6'b001000: begin // ADDI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000; // ADDI
            end
            6'b001100: begin // ANDI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00100; // ANDI
            end
            6'b001101: begin // ORI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00101; // ORI
            end
            6'b001110: begin // XORI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00110; // XORI
            end
            6'b001010: begin // SLTI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00011; // SLTI
            end
            6'b001011: begin // SLTIU
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b01000; // SLTIU
            end
            6'b001111: begin // LUI
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00111; // LUI
            end
            6'b000010: begin // J
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000;
            end
            6'b000011: begin // JAL
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000;
            end
            default: begin
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 0;
                alu_op = 5'b00000;
            end
        endcase
    end
endmodule 