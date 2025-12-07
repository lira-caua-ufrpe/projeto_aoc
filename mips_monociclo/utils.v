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
 * Arquivo: utils.v
 * Descrição:
 * Coleção de módulos utilitários usados no Datapath:
 * - Multiplexadores (2:1 e 4:1)
 * - Somadores (Adder) para PC e Branch
 * - Extensor de Sinal (Sign Extend) configurável
 * - Unidade de cálculo de endereço de Jump
 * -----------------------------------------------------------------------------
 */

// --- Multiplexador 2:1 de 32 bits ---
module mux_32(
    input wire [31:0] in1, // Entrada 0
    input wire [31:0] in2, // Entrada 1
    input wire sel,        // Seletor
    output wire [31:0] out
);
    assign out = sel ? in2 : in1;
endmodule

// --- Multiplexador 4:1 de 32 bits ---
// Usado para selecionar a fonte do próximo PC
module mux_32_4(
    input wire [31:0] in1, // 00: PC+4
    input wire [31:0] in2, // 01: Branch
    input wire [31:0] in3, // 10: Jump
    input wire [31:0] in4, // 11: Jump Register
    input wire [1:0] sel,
    output wire [31:0] out
);
    assign out = sel[1] ? (sel[0] ? in4 : in3) : (sel[0] ? in2 : in1);
endmodule

// --- Multiplexador 4:1 de 5 bits ---
// Usado para selecionar o registrador de destino (rd, rt ou $31)
module mux_5_4(
    input wire [4:0] in1,  // 00: rt (Instrução I)
    input wire [4:0] in2,  // 01: rd (Instrução R)
    input wire [4:0] in3,  // 10: $31 (JAL - Return Address)
    input wire [4:0] in4,  // 11: $0 (Não usado/Reserva)
    input wire [1:0] sel,
    output wire [4:0] out
);
    assign out = sel[1] ? (sel[0] ? in4 : in3) : (sel[0] ? in2 : in1);
endmodule

// --- Somador Simples para PC+4 ---
module adder_pc(
    input wire [31:0] pc,
    output wire [31:0] pc_plus_4
);
    assign pc_plus_4 = pc + 4;
endmodule

// --- Somador para cálculo de endereço de Branch ---
module adder_branch(
    input wire [31:0] pc_plus_4,
    input wire [31:0] sign_ext_shifted, // Imediato já deslocado (<<2)
    output wire [31:0] branch_addr
);
    assign branch_addr = pc_plus_4 + sign_ext_shifted;
endmodule

// --- Extensor de Sinal com controle ---
// is_signed=1: Estende o sinal (para aritméticos como ADDI, BEQ)
// is_signed=0: Preenche com zeros (para lógicos como ANDI, ORI)
module sign_extend(
    input wire [15:0] in,
    input wire is_signed,
    output wire [31:0] out
);
    assign out = is_signed ? {{16{in[15]}}, in} : {16'b0, in};
endmodule

// --- Unidade de Cálculo de Jump ---
// Concatena os 4 bits superiores do PC com o endereço do Jump deslocado
module jump_unit(
    input wire [3:0] pc_upper,
    input wire [25:0] jump_addr,
    output wire [31:0] jump_target
);
    assign jump_target = {pc_upper, jump_addr, 2'b00};
endmodule