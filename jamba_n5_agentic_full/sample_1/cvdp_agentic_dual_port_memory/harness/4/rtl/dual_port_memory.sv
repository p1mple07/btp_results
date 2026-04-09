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
    reg [DATA_WIDTH-1:0] ram_data;
    reg [ECC_WIDTH-1:0] ram_ecc;

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            ram_data <= 4'b0;
            ram_ecc <= 3'b0;
        end else begin
            if (we) begin
                // Write operation
                ram_data[addr_a] <= data_in;
                // Compute Hamming(7,4) parity bits
                reg [2:0] parity;
                parity = {data_in[2], data_in[1], data_in[0]};
                ram_ecc[addr_a] = parity;
            end else begin
                // Read operation
                data_out <= ram_data[addr_b];
                // Extract stored parity
                parity = {data_out[2], data_out[1], data_out[0]};
                // Compare with expected parity
                if (parity != ram_ecc) begin
                    ecc_error = 1;
                    data_out <= 4'b0;
                else
                    ecc_error = 0;
                    data_out <= data_out;
                end
            end
        end
    end

endmodule
