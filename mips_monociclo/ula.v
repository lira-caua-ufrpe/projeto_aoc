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
 * Arquivo: ula.v
 * Descrição:
 * Unidade Lógica e Aritmética (ALU) de 32 bits.
 * Realiza operações matemáticas (soma, subtração) e lógicas (AND, OR, XOR, etc.)
 * baseadas no sinal de controle 'alu_control'.
 * Também gera a flag 'zero' usada para decisões de desvio (branches).
 * -----------------------------------------------------------------------------
 */

module ula(
    input wire [31:0] a,          // Operando A (geralmente vem de rs)
    input wire [31:0] b,          // Operando B (vem de rt ou do imediato)
    input wire [4:0] shamt,       // Shift Amount (quantidade de deslocamento para shifts)
    input wire [3:0] alu_control, // Sinal de controle da operação (vindo da ula_ctrl)
    output reg [31:0] result,     // Resultado da operação
    output wire zero              // Flag Zero: '1' se o resultado for 0 (usado em BEQ/BNE)
);

    // Bloco combinacional para determinar o resultado
    always @(*) begin
        case (alu_control)
            // --- Operações Aritméticas ---
            4'b0010: result = a + b;       // ADD (Soma)
            4'b0110: result = a - b;       // SUB (Subtração)
            
            // --- Operações Lógicas ---
            4'b0000: result = a & b;       // AND
            4'b0001: result = a | b;       // OR
            4'b0011: result = a ^ b;       // XOR
            4'b0100: result = ~(a | b);    // NOR
            
            // --- Comparações (Set Less Than) ---
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT (Com sinal)
            4'b1000: result = (a < b) ? 32'b1 : 32'b0;                    // SLTU (Sem sinal)
            
            // --- Operações de Deslocamento (Shift) ---
            // Usam o campo 'shamt' da instrução como quantidade
            4'b1001: result = b << shamt;  // SLL (Shift Left Logical)
            4'b1010: result = b >> shamt;  // SRL (Shift Right Logical)
            4'b1111: result = $signed($signed(b) >>> shamt); // SRA (Shift Right Arithmetic - mantém sinal)
            
            // --- Shifts Variáveis (Usam registrador 'a' como quantidade) ---
            4'b1100: result = b << a;      // SLLV
            4'b1101: result = b >> a;      // SRLV
            4'b1110: result = $signed($signed(b) >>> a);     // SRAV (Aritmético variável)
            
            // --- Outros ---
            4'b1011: result = b << 16;     // LUI (Load Upper Immediate) - joga o imediato para o topo
            
            default: result = 32'b0;       // Segurança
        endcase
    end

    // Flag Zero: ativa se o resultado for exatamente zero
    assign zero = (result == 32'b0);

endmodule