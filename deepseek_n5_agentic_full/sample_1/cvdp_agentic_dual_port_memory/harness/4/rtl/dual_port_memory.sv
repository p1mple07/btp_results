module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ECC_WIDTH = 3,
    parameter ADDR_WIDTH = 5
)(
    input clock,
    input rst_n,
    input we,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg [ECC_WIDTH-1:0] ecc_error
)( 
    input [ADDR_WIDTH-1:0] addr_b,
    output [DATA_WIDTH-1:0] data_out,
    output [ECC_WIDTH-1:0] ecc_error
) 
{
    // Define dual-port memory
    reg [DATA_WIDTH-1:0] ram_data [((1 << ADDR_WIDTH))-1:0];
    reg [ECC_WIDTH-1:0] ram_ecc [((1 << ADDR_WIDTH))-1:0];
    
    // ECC-related variables
    reg [ECC_WIDTH-1:0] data_ecc;
    reg [ECC_WIDTH-1:0] expected_ecc;
    
    // Initialize registers to 0
    init begin
        data_out = 0;
        ecc_error = 0;
    end
    
    // Define functions for ECC calculations
    function {    
        // Extract data bits for ECC calculation
        data_ecc = data_in;
        
        // Calculate even parity bits
        expected_ecc[0] = data_ecc[0] ^ data_ecc[1] ^ data_ecc[3];
        expected_ecc[1] = data_ecc[0] ^ data_ecc[2] ^ data_ecc[3];
        expected_ecc[2] = data_ecc[1] ^ data_ecc[2] ^ data_ecc[3];
    } whenever(data_in or addr_a);
    
    // Always blocks
    always @posedge clock begin
        if (!rst_n) begin
            data_out <= 0;
            ecc_error <= 0;
        else begin
            if (we) begin
                // Write operation
                ram_data[addr_a] <= data_in;
                
                // Store data_ecc in the ECC section
                ram_ecc[addr_a] <= data_ecc;
            else begin
                // Read operation
                data_word <= ram_data[addr_b];
                ecc_word <= ram_ecc[addr_b];
                
                // Recompute ECC from data_word
                data_ecc = data_word;
                expected_ecc[0] = data_ecc[0] ^ data_ecc[1] ^ data_ecc[3];
                expected_ecc[1] = data_ecc[0] ^ data_ecc[2] ^ data_ecc[3];
                expected_ecc[2] = data_ecc[1] ^ data_ecc[2] ^ data_ecc[3];
                
                // Calculate syndrome
                ecc_error <= (expected_ecc[0] ^ ecc_word[0]) 
                            | (expected_ecc[1] ^ ecc_word[1])
                            | (expected_ecc[2] ^ ecc_word[2]);
            end
        end
    end
}