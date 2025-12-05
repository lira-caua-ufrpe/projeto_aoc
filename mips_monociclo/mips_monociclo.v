// ------------------------------------------------------------
// Grupo: Cauã Lira, Lucas Emanuel e Sérgio Ricardo
// Atividade: 2VA - Projeto Monociclo
// Disciplina: Arquitetura e Organização de Computadores
// Semestre letivo: 2025.2
// Arquivo: mips_monociclo.v
// Questão: Núcleo MIPS (Top-level)
// Descrição: Módulo toplevel em Verilog que integra todos os
//            módulos do processador MIPS monociclo, recebendo
//            clock e reset e expondo PC, saída da ULA e saída
//            da memória de dados.
// ------------------------------------------------------------

module mips_monociclo(
    input wire clk,
    input wire reset,
    // Apenas os sinais mais importante
    output wire [31:0] pc_out,
    output wire [31:0] alu_result_out,
    output wire [31:0] mem_data_out,
    output wire [31:0] instr_out,
    output wire [4:0] alu_control_out,
    output wire zero_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire [1:0] pc_source_out
);
    // Fios internos
    wire [31:0] pc, next_pc, instr, rd1, rd2, alu_b, alu_result, mem_data, write_data;
    wire [31:0] sign_ext_imm, branch_addr, pc_plus_4, jump_addr;
    wire [4:0] write_reg;
    wire [3:0] alu_control;
    wire [4:0] alu_op;
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, zero;
    wire branch_beq, branch_bne;
    wire [5:0] opcode, funct;
    wire [4:0] shamt;
    wire [1:0] pc_source;
    wire j, jal, jr;
    assign shamt = instr[10:6];

    // PC
    PC pc_reg(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Memória de instrução
    i_mem instr_mem(
        .addr(pc),
        .instr(instr)
    );

    assign opcode = instr[31:26];
    assign funct = instr[5:0];

    // Unidade de controle
    ctrl control(
        .opcode(opcode),
        .funct(funct),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .branch_beq(branch_beq),
        .branch_bne(branch_bne),
        .alu_op(alu_op)
    );

    // Módulos auxiliares
    adder_pc pc_adder(pc, pc_plus_4);
    adder_branch branch_adder(pc_plus_4, sign_ext_imm << 2, branch_addr);
    jump_unit jump_mod(pc_plus_4[31:28], instr[25:0], jump_addr);
    sign_extend sign_ext(instr[15:0], 1'b1, sign_ext_imm); // Assumindo signed por padrão

    // Detecção de instruções
    assign j = (opcode == 6'b000010);
    assign jal = (opcode == 6'b000011);
    assign jr = (opcode == 6'b000000 && funct == 6'b001000);
    // assign bne = (opcode == 6'b000101); // Não é mais necessário

    // Controle do PC
    assign pc_source[0] = (branch_beq && zero) || (branch_bne && ~zero);
    assign pc_source[1] = j || jal || jr;
    
    // Multiplexador para próximo PC
    mux_32_4 pc_mux(pc_plus_4, branch_addr, jump_addr, rd1, pc_source, next_pc);

    // Banco de registradores
    regfile regs(
        .clk(clk),
        .reset(reset),
        .ra1(instr[25:21]),
        .ra2(instr[20:16]),
        .wa(write_reg),
        .wd(write_data),
        .we(reg_write),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Seleção do registrador de escrita usando multiplexador
    mux_5_4 reg_mux(instr[20:16], instr[15:11], 5'd31, 5'd0, {jal, reg_dst}, write_reg);

    // Seleção do operando B da ULA
    mux_32 alu_mux(rd2, sign_ext_imm, alu_src, alu_b);

    // Unidade de controle da ULA
    ula_ctrl alucontrol(
        .alu_op(alu_op),
        .funct(funct),
        .alu_control(alu_control)
    );

    // ULA
    ula alu(
        .a(rd1),
        .b(alu_b),
        .shamt(shamt),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Memória de dados
    d_mem datamem(
        .clk(clk),
        .addr(alu_result),
        .write_data(rd2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_data)
    );

    // Seleção do dado a ser escrito no registrador
    wire [31:0] mem_to_reg_data;
    mux_32 mem_reg_mux(alu_result, mem_data, mem_to_reg, mem_to_reg_data);
    
    // Seleção final de dados (memória ou JAL)
    mux_32 final_data_mux(mem_to_reg_data, pc_plus_4, jal, write_data);

    // Outputs otimizados (apenas os mais importantes)
    assign pc_out = pc;
    assign alu_result_out = alu_result;
    assign mem_data_out = mem_data;
    assign instr_out = instr;
    assign alu_control_out = alu_control;
    assign zero_out = zero;
    assign mem_read_out = mem_read;
    assign mem_write_out = mem_write;
    assign pc_source_out = pc_source;

endmodule 
