# Processador MIPS Monociclo - Verilog

![Status](https://img.shields.io/badge/Status-Finalizado-green)
![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Tool](https://img.shields.io/badge/Quartus-20.1-blue)
![Course](https://img.shields.io/badge/Course-Arquitetura_de_Computadores-orange)

## 📋 Sobre o Projeto

Este projeto consiste na implementação de um processador **MIPS (Microprocessor without Interlocked Pipeline Stages)** de ciclo único (monociclo) em Verilog. O projeto foi desenvolvido como parte da avaliação da disciplina de **Arquitetura e Organização de Computadores (2025.2)** da **Universidade Federal Rural de Pernambuco (UFRPE)**, ministrada pelo **Prof. Vítor A Coutinho**.

O objetivo é criar um núcleo funcional capaz de executar um subconjunto da ISA (Instruction Set Architecture) MIPS32, incluindo instruções aritméticas, lógicas, de memória e de desvio.

---

## 👥 Equipe
* **Cauã Lira**
* **Lucas Emmanuel**
* **Sérgio Ricardo**

---

## ⚙️ Arquitetura e Organização

O projeto segue a arquitetura de MIPS monociclo padrão. O hardware foi modularizado para garantir organização e facilidade de manutenção.

### Módulos Principais
* **`mips_monociclo.v` (Top-Level):** Módulo principal que integra todos os componentes.
* **`ctrl.v` (Unidade de Controle):** Decodifica o `opcode` e gera os sinais de controle.
* **`ula.v` & `ula_ctrl.v`:** Execução de operações aritméticas e lógicas.
* **`regfile.v`:** Banco de Registradores ($0 fixo em zero).
* **`PC.v`:** Contador de Programa.
* **`i_mem.v` & `d_mem.v`:** Memórias de Instrução e Dados.
* **`utils.v`:** Multiplexadores, Extensores de Sinal e Somadores.

---

## 🚀 Conjunto de Instruções (ISA)

| Tipo | Instruções Suportadas |
| :--- | :--- |
| **Tipo R** | `add`, `sub`, `and`, `or`, `xor`, `nor`, `slt`, `sltu`, `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`, `jr` |
| **Tipo I** | `lw`, `sw`, `beq`, `bne`, `addi`, `andi`, `ori`, `xori`, `slti`, `sltiu`, `lui` |
| **Tipo J** | `j`, `jal` |

---

## 🛠️ Guia de Execução (Passo a Passo)

Siga este guia rigorosamente para evitar erros de licença ou simulação no Quartus.

### 1. Pré-requisitos
* **Software:** Intel Quartus Prime Lite Edition.
* **Versão Obrigatória:** **20.1 ou 20.1.1** (Versões mais novas exigem licença paga para rodar certos testes).

### 2. Configuração Inicial do Quartus
Antes de abrir o projeto, é necessário apontar o caminho do simulador manualmente:
1.  Vá em `Tools` > `Options` > `EDA Tool Options`.
2.  Verifique o campo **ModelSim-Altera**. Ele deve apontar para a pasta `win32aloem` (Windows) ou `linuxaloem` (Linux).
    * **Exemplo (Windows):** `C:\intelFPGA_lite\20.1\modelsim_ase\win32aloem`
    * **Exemplo (Linux):** `.../modelsim_ase/linuxaloem`
3.  Se estiver vazio, procure onde o Quartus foi instalado e copie esse caminho. Ambos os campos de ModelSim devem apontar para o mesmo local.

### 3. Abrindo e Compilando o Projeto
1.  **Criar/Abrir:** Vá em `File` > `New Project Wizard`.
2.  **Diretório:** Selecione a pasta onde estão os arquivos `.v`.
3.  **Nome do Projeto:** Deve ser **exatamente** o mesmo nome do módulo principal: `mips_monociclo`.
4.  **Adicionar Arquivos:** Selecione todos os arquivos `.v` da pasta.
5.  **Top-Level Entity:** Após o projeto abrir, vá na janela "Project Navigator" (à esquerda), clique com o botão direito em `mips_monociclo.v` e selecione **"Set as Top-Level Entity"**.
6.  **Configuração de Simulação (Importante):**
    * Vá em `Assignments` > `Settings` > **`EDA Tool Settings`**.
    * Na seção **Simulation**, configure exatamente assim:
        * **Tool name:** `ModelSim-Altera`
        * **Format(s):** `Verilog HDL`
7.  **Compilar:** Clique no botão **Start Compilation** (Play Azul).

### 4. Visualizando o Hardware (RTL Viewer)
Para provar que o código gerou o circuito correto:
1.  Vá em `Tools` > `Netlist Viewers` > **`RTL Viewer`**.
2.  Mostre os blocos conectados (PC, ULA, Memórias).

### 5. Simulação (Waveform)
Para ver as ondas e os clocks funcionando:

1.  **Criar Waveform:** `File` > `New` > `University Program VWF`.
2.  **Importar Sinais:**
    * Clique com botão direito na esquerda > `Insert Node or Bus` > `Node Finder`.
    * Clique em `List` > `>>` (Importar tudo) > `OK`.
3.  **Configurar Clock:**
    * Selecione o sinal `clk`.
    * Clique no ícone de "Relógio" na barra superior e defina como `10 ns`.
4.  **Configurar Reset:**
    * Selecione o sinal `reset`.
    * Force como `1` no primeiro ciclo e `0` no restante (para inicializar o PC).
5.  **Correção antes de simular:**
    * Vá em `Simulation` > **`Simulation Settings`**.
    * Procure uma caixa de texto com comandos/parâmetros.
    * **Apague** o comando `-novopt` (ou `novopt`) se ele estiver lá. Isso evita o erro de simulação.
    * Salve.
6.  **Rodar:** Clique no ícone **Run Functional Simulation** (o primeiro ícone de script, não o do relógio).

### 6. Analisando os Resultados
Na janela de simulação:
1.  Mude a base numérica dos sinais `pc_out`, `instr_out` e `alu_result_out` para **Decimal** ou **Hexadecimal** (clique com botão direito > Radix).
2.  **O que observar:**
    * **PC:** Deve incrementar de 4 em 4 (exceto em branches/jumps).
    * **Instrução:** Deve mudar logo após o PC mudar.
    * **ALU Result:** Deve mostrar o resultado da operação matemática correspondente à instrução.

---

## 📂 Estrutura de Arquivos

```text
.
├── mips_monociclo.v       # Módulo Top-Level (Nome do projeto deve ser este)
├── ctrl.v                 # Unidade de Controle
├── ula.v                  # ULA
├── ula_ctrl.v             # Controle da ULA
├── regfile.v              # Banco de Registradores
├── i_mem.v                # Memória de Instruções
├── d_mem.v                # Memória de Dados
├── PC.v                   # Program Counter
├── utils.v                # Muxes, Extensores, Somadores
├── instructions.list      # Arquivo BINÁRIO/HEX com o código a ser rodado
└── README.md              # Este arquivo
```

## 📜 Licença
Este projeto é de cunho acadêmico, desenvolvido para fins de aprendizado na UFRPE.
