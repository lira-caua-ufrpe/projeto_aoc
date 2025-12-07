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
 * Arquivo: regfile.v
 * Descrição:
 * Banco de Registradores (Register File) contendo 32 registradores de 32 bits.
 * - Leitura assíncrona (combinacional) em duas portas (rd1, rd2).
 * - Escrita síncrona (na borda do clock) na porta de escrita (wd).
 * - O registrador $0 (endereço 0) é fixo em zero (hardwired).
 * -----------------------------------------------------------------------------
 */

module regfile(
    input wire clk,             // Clock do sistema
    input wire reset,           // Reset para zerar todos os registradores
    input wire [4:0] ra1,       // Read Address 1 (índice do reg para rd1)
    input wire [4:0] ra2,       // Read Address 2 (índice do reg para rd2)
    input wire [4:0] wa,        // Write Address (onde escrever)
    input wire [31:0] wd,       // Write Data (dado a ser escrito)
    input wire we,              // Write Enable (habilita escrita)
    output wire [31:0] rd1,     // Read Data 1 (saída assíncrona)
    output wire [31:0] rd2      // Read Data 2 (saída assíncrona)
);

    // Declaração da matriz de registradores: 32 registradores de 32 bits
    reg [31:0] regs [0:31];
    integer i;

    // Bloco de Escrita (Síncrono)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Zera todos os registradores no reset
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        // Só escreve se o Write Enable (we) estiver ativo E se o destino não for $0
        else if (we && wa != 0) begin
            regs[wa] <= wd;
        end
    end

    // Leitura Assíncrona (Acontece o tempo todo)
    // O registrador $0 sempre retorna 0, independente do que tenha sido gravado lá
    assign rd1 = (ra1 == 0) ? 32'b0 : regs[ra1];
    assign rd2 = (ra2 == 0) ? 32'b0 : regs[ra2];

endmodule