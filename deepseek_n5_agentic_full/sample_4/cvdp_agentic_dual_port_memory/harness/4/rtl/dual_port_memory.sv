Module dual_port_memory.sv modified for ECC-based error detection using Hamming(7,4) code

module dual_port_memory #(
    parameter DATA_WIDTH = 4,  // Data width
    parameter ADDR_WIDTH = 5,  // Address width
    parameter ECC_WIDTH = 3,   // Width of ECC code (Hamming(7,4))
    parameter MEM_DEPTH = (1 << ADDR_WIDTH)  // Explicit memory depth
)(
    input clock, 
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,       // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,       // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
    output reg [ECC_WIDTH-1:0] ecc_error  // ECC error detection
);

    // Define RAM
    reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];
    reg [ECC_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    // ECC-related variables
    reg [ECC_WIDTH-1:0] data_ecc;          // Computed ECC for data_in
    reg [ECC_WIDTH-1:0] temp_ecc;         // Temporary storage for ECC

    // Logic to compute Hamming(7,4) parity bits
    data_ecc[0] = data_in[0] ^ data_in[1] ^ data_in[3];  // p0 = d0 ^ d1 ^ d3
    data_ecc[1] = data_in[0] ^ data_in[2] ^ data_in[3];  // p1 = d0 ^ d2 ^ d3
    data_ecc[2] = data_in[1] ^ data_in[2] ^ data_in[3];  // p2 = d1 ^ d2 ^ d3

    // Write operation (we == 1)
    always @(posedge clock) begin
        if (!rst_n) begin
            data_out <= 0;
            ram_ecc <= 0;
        end else begin
            if (we) begin
                ram_data[addr_a] <= data_in;
                ram_ecc[addr_a] <= data_ecc;
            end else begin
                    data_out <= ram_data[addr_b];
            end
        end
    end

    // Read operation (we == 0)
    always @(posedge clock) begin
        if (!rst_n) begin
            ram_ecc <= 0;
            data_ecc <= 0;
        end else begin
            if (we) begin
                // Recompute ECC from data
                temp_ecc[0] = ram_data[addr_b][0] ^ ram_data[addr_b][1] ^ ram_data[addr_b][3];
                temp_ecc[1] = ram_data[addr_b][0] ^ ram_data[addr_b][2] ^ ram_data[addr_b][3];
                temp_ecc[2] = ram_data[addr_b][1] ^ ram_data[addr_b][2] ^ ram_data[addr_b][3];
                
                // Calculate syndrome
                ecc_error = (temp_ecc ^ ram_ecc[addr_b]) ? 1 : 0;
                
                // Pass through data regardless of error
                data_out <= ram_data[addr_b];
            end
        end
    end
endmodule