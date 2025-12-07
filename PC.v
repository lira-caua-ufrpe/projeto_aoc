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
 * Arquivo: PC.v
 * Descrição:
 * Registrador do Contador de Programa (Program Counter).
 * Armazena o endereço da instrução atual.
 * Atualiza o endereço na borda de subida do clock.
 * -----------------------------------------------------------------------------
 */

module PC(
    input wire clk,             // Clock
    input wire reset,           // Reset síncrono/assíncrono
    input wire [31:0] next_pc,  // Próximo endereço calculado (PC+4, Branch, Jump...)
    output reg [31:0] pc        // Endereço atual
);

    // Atualização do PC na borda de subida
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;      // Reseta para o endereço inicial (geralmente 0 ou 0x00400000)
        else
            pc <= next_pc;    // Carrega o próximo valor
    end

endmodule