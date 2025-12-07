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
 * Arquivo: ctrl.v
 * Descrição:
 * Unidade de Controle Principal do processador MIPS.
 * Responsável por decodificar o Opcode (6 bits) da instrução e gerar os
 * sinais de controle necessários para o Datapath (caminho de dados).
 * Controla muxes, escritas em memória/registradores e operações de ALU.
 * Agora inclui o sinal 'is_signed' para diferenciar extensões de sinal/zero.
 * -----------------------------------------------------------------------------
 */

module ctrl(
    input wire [5:0] opcode,    // Opcode da instrução (bits 31-26)
    input wire [5:0] funct,     // Campo de função (bits 5-0), usado para distinguir instruções tipo R
    
    // --- Sinais de Controle de Saída ---
    output reg reg_dst,         // Seleciona registrador de destino: 0=rt (Tipo I), 1=rd (Tipo R)
    output reg alu_src,         // Seleciona operando B da ULA: 0=Registrador, 1=Imediato
    output reg mem_to_reg,      // Seleciona dado para escrita no reg: 0=ULA, 1=Memória
    output reg reg_write,       // Habilita escrita no Banco de Registradores (1=Escreve)
    output reg mem_read,        // Habilita leitura da Memória de Dados (1=Lê)
    output reg mem_write,       // Habilita escrita na Memória de Dados (1=Escreve)
    output reg branch,          // Sinal geral indicando instrução de desvio condicional
    output reg branch_beq,      // Sinal específico para Branch Equal (BEQ)
    output reg branch_bne,      // Sinal específico para Branch Not Equal (BNE)
    output reg [4:0] alu_op,    // Código enviado para a ula_ctrl decidir a operação específica
    output reg is_signed        // Controle de extensão: 1=Sinal (aritmético), 0=Zero (lógico)
);

    // Bloco combinacional para decodificação
    always @(*) begin
        // --- Valores Padrão (Default) ---
        // Inicializa tudo com 0 para evitar latches indesejados e comportamento indefinido
        reg_dst = 0;
        alu_src = 0;
        mem_to_reg = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        branch_beq = 0;
        branch_bne = 0;
        alu_op = 5'b00000;
        is_signed = 1; // O padrão é estender o sinal (para LW, SW, BEQ, ADDI)

        case (opcode)
            // -----------------------------------------------------------------
            // Instruções Tipo R (Opcode 000000)
            // -----------------------------------------------------------------
            6'b000000: begin 
                // Caso especial: JR (Jump Register)
                if (funct == 6'b001000) begin 
                    // JR apenas atualiza o PC, não escreve em registradores nem memória
                    reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
                    mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                    alu_op = 5'b00010; // Código genérico para Tipo R
                end else begin 
                    // Outras instruções Tipo R (ADD, SUB, AND, OR, SLT, Shifts...)
                    reg_dst = 1;       // O destino é o campo 'rd' (bits 15-11)
                    alu_src = 0;       // O segundo operando vem do registrador (rt)
                    mem_to_reg = 0;    // O resultado vem da ULA
                    reg_write = 1;     // Habilita escrita no registrador de destino
                    mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                    alu_op = 5'b00010; // Indica para ula_ctrl olhar o campo 'funct'
                end
            end

            // -----------------------------------------------------------------
            // Instruções de Acesso à Memória (Tipo I)
            // -----------------------------------------------------------------
            6'b100011: begin // LW (Load Word)
                reg_dst = 0;       // O destino é o campo 'rt' (bits 20-16)
                alu_src = 1;       // Soma registrador base + imediato (offset)
                mem_to_reg = 1;    // O dado a ser escrito vem da Memória de Dados
                reg_write = 1;     // Habilita escrita
                mem_read = 1;      // Habilita leitura da memória
                mem_write = 0;
                branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000; // ULA faz soma para calcular endereço
            end
            6'b101011: begin // SW (Store Word)
                reg_dst = 0;       // Destino irrelevante (não escreve em reg)
                alu_src = 1;       // Soma registrador base + imediato
                mem_to_reg = 0;
                reg_write = 0;     // Desabilita escrita em registrador
                mem_read = 0;
                mem_write = 1;     // Habilita escrita na memória
                branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000; // ULA faz soma para calcular endereço
            end

            // -----------------------------------------------------------------
            // Instruções de Desvio Condicional (Branch)
            // -----------------------------------------------------------------
            6'b000100: begin // BEQ (Branch on Equal)
                reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
                mem_read = 0; mem_write = 0;
                branch = 1;        // Sinaliza que é um branch
                branch_beq = 1;    // Ativa lógica BEQ
                branch_bne = 0;
                alu_op = 5'b00001; // ULA faz subtração para comparar valores
            end
            6'b000101: begin // BNE (Branch on Not Equal)
                reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
                mem_read = 0; mem_write = 0;
                branch = 0;
                branch_beq = 0;
                branch_bne = 1;    // Ativa lógica BNE
                alu_op = 5'b00001; // ULA faz subtração para comparar valores
            end

            // -----------------------------------------------------------------
            // Instruções Aritméticas Imediatas (Tipo I)
            // -----------------------------------------------------------------
            6'b001000: begin // ADDI (Add Immediate)
                reg_dst = 0;       // Destino é 'rt'
                alu_src = 1;       // Segundo operando é o imediato
                mem_to_reg = 0;    // Resultado vem da ULA
                reg_write = 1;     // Habilita escrita
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000; // ULA faz soma
            end

            // -----------------------------------------------------------------
            // Instruções Lógicas Imediatas (Tipo I - Zero Extend)
            // -----------------------------------------------------------------
            6'b001100: begin // ANDI (AND Immediate)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00100; // Operação AND
                is_signed = 0;     // Desativa extensão de sinal (preenche com zeros)
            end
            6'b001101: begin // ORI (OR Immediate)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00101; // Operação OR
                is_signed = 0;     // Desativa extensão de sinal
            end
            6'b001110: begin // XORI (XOR Immediate)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00110; // Operação XOR
                is_signed = 0;     // Desativa extensão de sinal
            end

            // -----------------------------------------------------------------
            // Outras Instruções Imediatas
            // -----------------------------------------------------------------
            6'b001010: begin // SLTI (Set on Less Than Immediate - Signed)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00011; // Operação SLT
            end
            6'b001011: begin // SLTIU (Set on Less Than Imm - Unsigned)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b01000; // Operação SLTU
            end
            6'b001111: begin // LUI (Load Upper Immediate)
                reg_dst = 0; alu_src = 1; mem_to_reg = 0; reg_write = 1;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00111; // Operação LUI
            end

            // -----------------------------------------------------------------
            // Instruções de Salto Incondicional (Jumps)
            // -----------------------------------------------------------------
            6'b000010: begin // J (Jump)
                reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000;
            end
            6'b000011: begin // JAL (Jump and Link)
                reg_dst = 0; alu_src = 0; mem_to_reg = 0; 
                reg_write = 1; // Habilita escrita (salvar PC+4 no $ra)
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000;
            end

            // -----------------------------------------------------------------
            // Default (Segurança)
            // -----------------------------------------------------------------
            default: begin
                reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
                mem_read = 0; mem_write = 0; branch = 0; branch_beq = 0; branch_bne = 0;
                alu_op = 5'b00000; is_signed = 1;
            end
        endcase
    end
endmodule