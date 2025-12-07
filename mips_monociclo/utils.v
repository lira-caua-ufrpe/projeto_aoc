// ------------------------------------------------------------
// Grupo: Cauã Lira, Lucas Emanuel e Sérgio Ricardo
// Atividade: 2VA - Projeto Monociclo
// Disciplina: Arquitetura e Organização de Computadores
// Semestre letivo: 2025.2
// Arquivo: utils.v
// Questão: Módulos auxiliares do datapath MIPS
// Descrição: Implementa multiplexadores, somadores, extensão de sinal
//            e unidade de jump utilizados na integração do MIPS monociclo.
// ------------------------------------------------------------


// Módulos auxiliares para o processador MIPS monociclo

// Multiplexador 2:1 de 32 bits
module mux_32(
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire sel,
    output wire [31:0] out
);
    assign out = sel ? in2 : in1;
endmodule

// Multiplexador 4:1 de 32 bits
module mux_32_4(
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [31:0] in4,
    input wire [1:0] sel,
    output wire [31:0] out
);
    assign out = sel[1] ? (sel[0] ? in4 : in3) : (sel[0] ? in2 : in1);
endmodule

// Multiplexador 4:1 de 5 bits (para seleção de registrador)
module mux_5_4(
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [4:0] in3,
    input wire [4:0] in4,
    input wire [1:0] sel,
    output wire [4:0] out
);
    assign out = sel[1] ? (sel[0] ? in4 : in3) : (sel[0] ? in2 : in1);
endmodule

// Somador para incremento do PC
module adder_pc(
    input wire [31:0] pc,
    output wire [31:0] pc_plus_4
);
    assign pc_plus_4 = pc + 4;
endmodule

// Somador para cálculo de branch
module adder_branch(
    input wire [31:0] pc_plus_4,
    input wire [31:0] sign_ext_shifted,
    output wire [31:0] branch_addr
);
    assign branch_addr = pc_plus_4 + sign_ext_shifted;
endmodule

// Extensão de sinal com controle signed/unsigned
module sign_extend(
    input wire [15:0] in,
    input wire is_signed,
    output wire [31:0] out
);
    assign out = is_signed ? {{16{in[15]}}, in} : {16'b0, in};
endmodule

// Módulo de jump
module jump_unit(
    input wire [3:0] pc_upper,
    input wire [25:0] jump_addr,
    output wire [31:0] jump_target
);
    assign jump_target = {pc_upper, jump_addr, 2'b00};
endmodule 
