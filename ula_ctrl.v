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
 * Arquivo: ula_ctrl.v
 * Descrição:
 * Unidade de Controle da ULA (ALU Control).
 * Responsável por traduzir o sinal 'alu_op' (vindo do controle principal)
 * e o campo 'funct' (da instrução) em um sinal de controle específico
 * para a ULA (alu_control). Define a operação exata (ADD, SUB, XOR, SLL...).
 * -----------------------------------------------------------------------------
 */

module ula_ctrl(
    input wire [4:0] alu_op,     // Código de operação vindo do módulo CTRL
    input wire [5:0] funct,      // Campo 'funct' da instrução (apenas para instruções Tipo R)
    output reg [3:0] alu_control // Código de seleção da operação na ULA
);

    always @(*) begin
        case (alu_op)
            // --- Operações que não dependem do campo FUNCT (Tipo I e J) ---
            5'b00000: alu_control = 4'b0010; // LW, SW, ADDI: ULA deve somar
            5'b00001: alu_control = 4'b0110; // BEQ, BNE: ULA deve subtrair (para comparação)
            
            // --- Operações Tipo R (Dependem do código FUNCT) ---
            5'b00010: begin 
                case (funct)
                    // Aritmética e Lógica Básica
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b100110: alu_control = 4'b0011; // XOR
                    6'b100111: alu_control = 4'b0100; // NOR
                    6'b101010: alu_control = 4'b0111; // SLT (Set on Less Than - Signed)
                    6'b101011: alu_control = 4'b1000; // SLTU (Set on Less Than - Unsigned)
                    
                    // Instruções de Deslocamento (Shifts com 'shamt')
                    6'b000000: alu_control = 4'b1001; // SLL (Shift Left Logical)
                    6'b000010: alu_control = 4'b1010; // SRL (Shift Right Logical)
                    6'b000011: alu_control = 4'b1111; // SRA (Shift Right Arithmetic)
                    
                    // Instruções de Deslocamento Variável (Shifts com registrador)
                    6'b000100: alu_control = 4'b1100; // SLLV
                    6'b000110: alu_control = 4'b1101; // SRLV
                    6'b000111: alu_control = 4'b1110; // SRAV
                    
                    // Instrução JR (Jump Register)
                    // JR não usa a ULA para cálculo, definimos um valor seguro
                    6'b001000: alu_control = 4'b1110; 
                    
                    default:   alu_control = 4'b0000; // Default seguro
                endcase
            end

            // --- Operações Imediatas Específicas (Definidas no CTRL principal) ---
            5'b00011: alu_control = 4'b0111; // SLTI
            5'b01000: alu_control = 4'b1000; // SLTIU
            
            // Lógicas Imediatas
            5'b00100: alu_control = 4'b0000; // ANDI (usa operação AND)
            5'b00101: alu_control = 4'b0001; // ORI (usa operação OR)
            5'b00110: alu_control = 4'b0011; // XORI (usa operação XOR) - Corrigido!
            
            5'b00111: alu_control = 4'b1011; // LUI (Load Upper Immediate)
            
            default: alu_control = 4'b0000;
        endcase
    end
endmodule