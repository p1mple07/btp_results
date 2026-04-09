module dual_port_memory #(
    parameter DATA_WIDTH = 4, 
    parameter ADDR_WIDTH = 5, 
    parameter MEM_DEPTH = 1 << ADDR_WIDTH  // 32 entries
)(
    input clk,
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,        // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,        // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
);

    // Dual‑port RAM registers
    reg [DATA_WIDTH-1:0] ram_data [0 : MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] ram_ecc [0 : MEM_DEPTH-1];

    // ECC helper variables
    localparam DATA_WIDTH_ECC = 3;
    localparam ADDR_WIDTH_ECC = 5;
    localparam MEM_DEPTH_ECC = 1 << ADDR_WIDTH_ECC;
    reg [DATA_WIDTH_ECC-1:0] ecc_word;
    reg [DATA_WIDTH_ECC_ECC:0] ecc_parity;

    // Counters for address indexing
    localparam offset_data = ADDR_WIDTH;
    localparam offset_ecc  = ADDR_WIDTH + DATA_WIDTH_ECC;

    // Clock driver
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
        end else begin
            if (we) begin
                ram_data[addr_a] <= data_in;
                // Hamming(7,4) encoding
                d0 = data_in[0]; d1 = data_in[1]; d2 = data_in[2]; d3 = data_in[3];
                p0 = d0 ^ d1 ^ d3;
                p1 = d0 ^ d2 ^ d3;
                p2 = d1 ^ d2 ^ d3;
                ecc_word = {d0, d1, d2, d3, p0, p1, p2};
                ram_ecc[addr_a] <= ecc_word;
            end
            else begin
                addr_b = offset_ecc + ((addr_b >> offset_data) * MEM_DEPTH_ECC);
                data_out <= ram_data[addr_b];
                // Decode the ECC bytes from the stored word
                d0 = data_out[0]; d1 = data_out[1]; d2 = data_out[2]; d3 = data_out[3];
                p0 = d0 ^ d1 ^ d3;
                p1 = d0 ^ d2 ^ d3;
                p2 = d1 ^ d2 ^ d3;
                ecc_word = {d0, d1, d2, d3, p0, p1, p2};
                if (ecc_word != ram_ecc[addr_b]) begin
                    ecc_error = 1'b1;
                else
                    ecc_error = 0'b0;
                end
            end
        end
    end

endmodule
