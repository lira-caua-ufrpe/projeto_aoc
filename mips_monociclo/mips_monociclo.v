/*
 * -----------------------------------------------------------------------------
 * Universidade Federal Rural de Pernambuco (UFRPE)
 * Disciplina: Arquitetura e Organização de Computadores
 * Semestre Letivo: 2025.2
 * Professor: Vítor A Coutinho
 * Atividade: Projeto 2 - Implementação de MIPS Monociclo (2ª VA)
 *
 * Grupo:
 * - Cauã Lira
 * - Lucas Emmanuel
 * - Sérgio Ricardo
 *
 * Arquivo: mips_monociclo.v
 * Descrição:
 * Módulo Top-Level do processador MIPS Monociclo.
 * Integra todos os componentes (PC, Memorias, Regfile, ULA, Controle) e
 * realiza as conexões (fios) entre eles.
 * Implementa a lógica de próximo PC (Next PC logic) para Branches e Jumps.
 * -----------------------------------------------------------------------------
 */

module mips_monociclo(
    input wire clk,             // Clock do sistema
    input wire reset,           // Reset síncrono/assíncrono
    
    // --- Saídas de Depuração (Outputs para Waveform) ---
    // Estes sinais são exportados para facilitar a visualização na simulação
    output wire [31:0] pc_out,          // Endereço atual do PC
    output wire [31:0] alu_result_out,  // Resultado da operação da ULA
    output wire [31:0] mem_data_out,    // Dado lido da memória
    output wire [31:0] instr_out,       // Instrução sendo executada
    output wire [4:0] alu_control_out,  // Sinal de controle da ULA
    output wire zero_out,               // Flag Zero da ULA
    output wire mem_read_out,           // Sinal de leitura da memória
    output wire mem_write_out,          // Sinal de escrita da memória
    output wire [1:0] pc_source_out     // Origem do próximo PC
);

    // --- Declaração de Fios Internos (Datapath) ---
    wire [31:0] pc, next_pc, instr;             // Sinais do PC e Instrução lida
    wire [31:0] rd1, rd2;                       // Saídas do Banco de Registradores
    wire [31:0] alu_b, alu_result;              // Operando B e Resultado da ULA
    wire [31:0] mem_data, write_data;           // Sinais da Memória de Dados e WriteBack
    wire [31:0] sign_ext_imm;                   // Imediato com extensão de sinal (16->32 bits)
    wire [31:0] branch_addr, pc_plus_4;         // Endereços calculados para Branch e PC+4
    wire [31:0] jump_addr;                      // Endereço de destino do Jump
    
    wire [4:0] write_reg;                       // Registrador de destino final (rd ou rt)
    wire [3:0] alu_control;                     // Sinal de controle decodificado para a ULA
    wire [4:0] alu_op;                          // Sinal intermediário de operação
    
    // Sinais de controle vindos da Unidade de Controle
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write;
    wire branch, zero;                          // Branch (geral) e Zero Flag
    wire branch_beq, branch_bne;                // Sinais específicos de Branch
    wire sign_ext_ctrl;                         // Controle de extensão (0=Zero, 1=Sinal)
    
    // Campos extraídos da instrução
    wire [5:0] opcode, funct;
    wire [4:0] shamt;
    
    // Sinais para lógica de salto
    wire [1:0] pc_source;
    wire j, jal, jr;

    // --- Atribuições Contínuas (Assigns) ---
    assign shamt = instr[10:6];     // Shift Amount (usado em sll, srl)
    assign opcode = instr[31:26];   // Opcode (bits 31-26)
    assign funct = instr[5:0];      // Function Code (bits 5-0)

    // Detecção rápida de tipos de salto baseada no opcode/funct
    assign j = (opcode == 6'b000010);
    assign jal = (opcode == 6'b000011);
    assign jr = (opcode == 6'b000000 && funct == 6'b001000);

    // --- Lógica do Próximo PC ---
    // bit 0: '1' se for BEQ e Zero=1, OU BNE e Zero=0, OU instrução JR
    assign pc_source[0] = (branch_beq && zero) || (branch_bne && ~zero) || jr;
    // bit 1: '1' se for qualquer tipo de Jump incondicional (J, JAL, JR)
    assign pc_source[1] = j || jal || jr;

    // --- Instanciação dos Módulos ---

    // 1. Program Counter (PC)
    PC pc_reg(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // 2. Memória de Instrução (ROM)
    // Lê a instrução baseada no endereço do PC
    i_mem instr_mem(
        .addr(pc),
        .instr(instr)
    );

    // 3. Unidade de Controle Principal
    // Decodifica o opcode e gera sinais de controle
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
        .alu_op(alu_op),
        .is_signed(sign_ext_ctrl) // Controla tipo de extensão (Sinal/Zero)
    );

    // 4. Somadores e Calculadores de Endereço
    adder_pc pc_adder(pc, pc_plus_4); // Calcula PC + 4
    adder_branch branch_adder(pc_plus_4, sign_ext_imm << 2, branch_addr); // Calcula alvo do Branch
    jump_unit jump_mod(pc_plus_4[31:28], instr[25:0], jump_addr); // Calcula alvo do Jump

    // 5. Extensor de Sinal (Configurável via sign_ext_ctrl)
    sign_extend sign_ext(instr[15:0], sign_ext_ctrl, sign_ext_imm);

    // 6. MUX do PC (Decide qual será o próximo endereço)
    // 00: PC+4 | 01: Branch | 10: Jump (J/JAL) | 11: Jump Register (rd1)
    mux_32_4 pc_mux(pc_plus_4, branch_addr, jump_addr, rd1, pc_source, next_pc);

    // 7. Banco de Registradores (RegFile)
    regfile regs(
        .clk(clk),
        .reset(reset),
        .ra1(instr[25:21]), // Endereço de Leitura 1 (rs)
        .ra2(instr[20:16]), // Endereço de Leitura 2 (rt)
        .wa(write_reg),     // Endereço de Escrita (calculado pelo Mux)
        .wd(write_data),    // Dado a ser escrito
        .we(reg_write),     // Habilita escrita
        .rd1(rd1),          // Saída de Dado 1
        .rd2(rd2)           // Saída de Dado 2
    );

    // MUX do Registrador de Destino: 
    // Escolhe entre rt (tipo I), rd (tipo R), ou $31 (para JAL)
    mux_5_4 reg_mux(instr[20:16], instr[15:11], 5'd31, 5'd0, {jal, reg_dst}, write_reg);

    // MUX da ULA: 
    // Escolhe entre Registrador (rd2) ou Imediato estendido (sign_ext_imm)
    mux_32 alu_mux(rd2, sign_ext_imm, alu_src, alu_b);

    // 8. Controle da ULA
    // Gera o sinal exato de controle para a ULA
    ula_ctrl alucontrol(
        .alu_op(alu_op),
        .funct(funct),
        .alu_control(alu_control)
    );

    // 9. Unidade Lógica e Aritmética (ULA)
    ula alu(
        .a(rd1),
        .b(alu_b),
        .shamt(shamt),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero) // Flag zero usada para decisões de Branch
    );

    // 10. Memória de Dados (RAM)
    d_mem datamem(
        .clk(clk),
        .addr(alu_result), // Endereço calculado pela ULA
        .write_data(rd2),  // Dado a ser gravado (Store)
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_data) // Dado lido (Load)
    );

    // MUX Mem-to-Reg: 
    // Escolhe se salva resultado da ULA ou dado da Memória
    wire [31:0] mem_to_reg_data;
    mux_32 mem_reg_mux(alu_result, mem_data, mem_to_reg, mem_to_reg_data);

    // MUX Final de Escrita: 
    // Escolhe o dado normal ou o PC+4 (caso seja instrução JAL)
    mux_32 final_data_mux(mem_to_reg_data, pc_plus_4, jal, write_data);

    // --- Conexão dos Outputs para Depuração ---
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