// --- Modified dual_port_memory.sv ---

module dual_port_memory #(
    parameter DATA_WIDTH = 4,  // Data width
    parameter ADDR_WIDTH = 5,  // Address width
    parameter MEM_DEPTH = 32    // 2^ADDR_WIDTH entries
)(
    input clk,
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,        // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,        // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
);

    // RAM array for dual‑port storage
    reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];
    reg [ECC_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    // Helper function to compute Hamming parity (7,4)
    localparam WIDTH = DATA_WIDTH;
    localparam PARITY_WIDTH = 3;

    function integer compute_parity(bits [WIDTH-1:0] data);
        integer p0, p1, p2;
        p0 = data[0] ^ data[1] ^ data[WIDTH-1];
        p1 = data[0] ^ data[2] ^ data[WIDTH-1];
        p2 = data[1] ^ data[2] ^ data[WIDTH-1];
        return {p0, p1, p2};
    endfunction

    // Stateful logic
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            ram_data[0] <= 4'b0;
            ram_ecc[0] <= 3'b000;
        end else begin
            if (we) begin
                // Write operation
                let data_to_store = data_in;
                let ecc = compute_parity(data_to_store);
                ram_data[addr_a] = data_to_store;
                ram_ecc[addr_a] = ecc;
            end else begin
                // Read operation
                let data_word = ram_data[addr_b];
                let ecc_word = ram_ecc[addr_b];
                let computed_ecc = compute_parity(data_word);
                let syndrome = xnor(ecc_word, computed_ecc, PARITY_WIDTH);
                ecc_error = syndrome != 3'b0;
                data_out <= data_word;
            end
        end
    end

endmodule
