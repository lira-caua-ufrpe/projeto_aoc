module i_mem(
    input wire [31:0] addr,
    output wire [31:0] instr
);
    // Parâmetros da memória
    parameter memory_size = 64;  // Reduzido para corresponder ao arquivo
    parameter address_data = 32;
    
    // Declaração da memória ROM
    reg [address_data-1:0] rom_mem [0:memory_size-1];
    
    // Inicializando o arquivo com as instruções MIPS
    initial begin
        $readmemb("instructions.list", rom_mem);
    end
    
    // Leitura assíncrona - word aligned
    assign instr = rom_mem[addr[address_data-1:2]];
endmodule 