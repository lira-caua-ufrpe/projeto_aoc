// ------------------------------------------------------------
// Grupo: Cauã Lira, Lucas Emanuel e Sérgio Ricardo
// Atividade: 2VA - Projeto Monociclo
// Disciplina: Arquitetura e Organização de Computadores
// Semestre letivo: 2025.2
// Arquivo: regfile.v
// Questão: Banco de registradores (regfile)
// Descrição: Implementa o banco de 32 registradores de 32 bits,
//            com leitura assíncrona em dois registradores e
//            escrita síncrona controlada por clock, reset e RegWrite.
// ------------------------------------------------------------



module regfile(
    input wire clk,
    input wire reset,
    input wire [4:0] ra1,
    input wire [4:0] ra2,
    input wire [4:0] wa,
    input wire [31:0] wd,
    input wire we,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [0:31];
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (we && wa != 0) begin
            regs[wa] <= wd;
        end
    end
    assign rd1 = regs[ra1];
    assign rd2 = regs[ra2];
endmodule 
