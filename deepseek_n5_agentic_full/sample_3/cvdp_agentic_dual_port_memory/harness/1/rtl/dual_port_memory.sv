module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 5
)(
    input clk,
    input we_a,
    input we_b,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] data_in_a,
    input [DATA_WIDTH-1:0] data_in_b,
    output reg [DATA_WIDTH-1:0] data_out_a,
    output reg [DATA_WIDTH-1:0] data_out_b
)

    reg [DATA_WIDTH:0] ram [(2**ADDR_WIDTH)-1:0];

    always @(posedgeclk or negedgeclk) begin
        if (we_a) begin
            data_out_a <= (ram[addr_a] ^ 4'b1010) >> 1;
            data_out_b <= ram[addr_b] & 3; // Use bitwise AND to ensure proper truncation
        end else begin
            data_out_a <= ram[addr_a] << 1;
            data_out_b <= ram[addr_b] & 3;
        end
    end
endmodule