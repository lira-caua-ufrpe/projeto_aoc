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
 * Arquivo: d_mem.v
 * Descrição:
 * Memória de Dados (RAM).
 * Usada pelas instruções LW (Load Word) e SW (Store Word).
 * Leitura pode ser combinacional ou síncrona (aqui implementada combinacional
 * para leitura e síncrona para escrita).
 * -----------------------------------------------------------------------------
 */

module d_mem(
    input wire clk,              // Clock (para escrita síncrona)
    input wire [31:0] addr,      // Endereço de acesso (calculado pela ULA)
    input wire [31:0] write_data,// Dado a ser escrito (vem de rt)
    input wire mem_write,        // Enable de escrita
    input wire mem_read,         // Enable de leitura
    output reg [31:0] read_data  // Dado lido
);

    // Declaração da RAM (256 palavras de 32 bits)
    reg [31:0] mem [0:255];

    // Escrita Síncrona (Borda de subida)
    always @(posedge clk) begin
        if (mem_write)
            // Endereçamento word-aligned (divide por 4)
            // addr[9:2] pega apenas os bits úteis para o tamanho desta memória
            mem[addr[9:2]] <= write_data;
    end

    // Leitura Combinacional/Assíncrona
    always @(*) begin
        if (mem_read)
            read_data = mem[addr[9:2]];
        else
            read_data = 32'b0; // Retorna 0 se não estiver lendo (segurança)
    end

endmodule