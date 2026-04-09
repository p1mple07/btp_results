module dual_port_memory #(
    parameter DATA_WIDTH = 4,  // Data width
    parameter ADDR_WIDTH = 5,  // Address width
    parameter MEM_DEPTH = 1 << ADDR_WIDTH  // Explicit memory depth
)(
    input clk,
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,        // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,        // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
);

    // Define RAM
    reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];
    reg [2:0] parities [MEM_DEPTH-1:0];
    reg [DATA_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            ram_data <= 0;
            ram_ecc <= 0;
        end else begin
            if (we) begin
                ram_data[addr_a] <= data_in;
                parities = {data_in[0], data_in[1], data_in[2], data_in[3]};
                ram_ecc[addr_a] = parities[0] ^ parities[1] ^ parities[2];
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            ram_data <= 0;
            ram_ecc <= 0;
        end else begin
            if (we) begin
                // Write operation
            end else begin
                // Read operation
            end
        end
    end

    assign data_out = (ram_data[addr_b] && !ecc_error) ? ram_data[addr_b] : data_out;

endmodule
