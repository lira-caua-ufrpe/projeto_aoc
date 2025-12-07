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
 * Arquivo: i_mem.v
 * Descrição:
 * Memória de Instruções (ROM).
 * Carrega o código binário do arquivo "instructions.list" no início da simulação.
 * É endereçada por palavra (word-aligned), ignorando os 2 bits menos significativos
 * do endereço de byte fornecido pelo PC.
 * -----------------------------------------------------------------------------
 */

module i_mem(
    input wire [31:0] addr,   // Endereço de leitura (vem do PC)
    output wire [31:0] instr  // Instrução lida
);

    // Parâmetros de tamanho da memória
    parameter memory_size = 256; // Quantidade de instruções suportadas
    
    // Declaração da memória (Array de reg)
    reg [31:0] rom_mem [0:memory_size-1];

    // Inicialização: Carrega o programa do arquivo externo
    initial begin
        // Lê arquivo binário/hexadecimal com as instruções
        $readmemb("instructions.list", rom_mem);
    end
    
    // Leitura Assíncrona
    // O MIPS endereça por byte, mas a memória organiza por palavra (32 bits).
    // Por isso, dividimos o endereço por 4 (deslocando >> 2) para achar o índice.
    assign instr = rom_mem[addr[31:2]];

endmodule