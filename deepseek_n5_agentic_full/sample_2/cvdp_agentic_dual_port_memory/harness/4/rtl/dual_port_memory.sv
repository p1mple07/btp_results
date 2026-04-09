module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 5,
    parameter ECC_WIDTH = 3,
    parameter MEM_DEPTH = (1 << ADDR_WIDTH)
)(
    input clk,
    input rst_n,
    input we,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg [ECC_WIDTH-1:0] ram_ecc
);

    // Define RAM
    reg [DATA_WIDTH-1:0] ram [MEM_DEPTH-1:0];
    reg [ECC_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
        end else begin
            if (we) begin
                // Compute ECC parity
                reg [ECC_WIDTH-1:0] ecc_parity = 0;
                ecc_parity[0] = ram[addr_a][0] ^ ram[addr_a][1] ^ ram[addr_a][3];
                ecc_parity[1] = ram[addr_a][0] ^ ram[addr_a][2] ^ ram[addr_a][3];
                ecc_parity[2] = ram[addr_a][1] ^ ram[addr_a][2] ^ ram[addr_a][3];
                
                ram[addr_a] <= data_in;
                ram_ecc[addr_a] <= ecc_parity;
            end else begin
                // Read from memory
                data_out <= ram[addr_b];
                // Recompute ECC
                reg [ECC_WIDTH-1:0] recomputed_ecc = 0;
                recomputed_ecc[0] = data_out[0] ^ data_out[1] ^ data_out[3];
                recomputed_ecc[1] = data_out[0] ^ data_out[2] ^ data_out[3];
                recomputed_ecc[2] = data_out[1] ^ data_out[2] ^ data_out[3];
                
                // Compare with stored ECC
                ram_ecc[addr_b] ^= recomputed_ecc;
                // Error detection
                if (ram_ecc[addr_b] != 0) begin
                    $display(" ECC ERROR: %0b", ram_ecc[addr_b]);
                    ecc_error = 1;
                end else begin
                    ecc_error = 0;
                end
            end
        end
    end
endmodule