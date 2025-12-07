module d_mem(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire mem_write,
    input wire mem_read,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:255];
    always @(posedge clk) begin
        if (mem_write)
            mem[addr[9:2]] <= write_data;
    end
    always @(*) begin
        if (mem_read)
            read_data = mem[addr[9:2]];
        else
            read_data = 32'b0;
    end
endmodule 