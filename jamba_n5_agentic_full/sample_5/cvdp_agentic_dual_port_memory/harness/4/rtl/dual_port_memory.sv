module dual_port_memory #(
    parameter DATA_WIDTH = 4,  // Data width
    parameter ADDR_WIDTH = 5,  // Address width
    parameter MEM_DEPTH = 32  // default 2^5 = 32
)(
    input clk,
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,        // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,        // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
    output reg ecc_error                  // ECC error signal
);

    // ... existing variables

    // New variables for ECC
    reg [3:0] ecc_word;
    reg [2:0] p0, p1, p2;
    reg [3:0] data_word;
    reg [2:0] addr_val;

    // RAM storage
    reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];
    reg [DATA_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    // Internal signals
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            ecc_error <= 0;
            ram_data[0:MEM_DEPTH-1] <= 0;
            ram_ecc[0:MEM_DEPTH-1] <= 0;
        end else begin
            case (we)
                'W: begin
                    // Write operation
                    addr_val = addr_a;
                    data_in = data_in;
                    // Compute ECC for data_in
                    p0 = data_in[0] ^ data_in[1] ^ data_in[2];
                    p1 = data_in[0] ^ data_in[2] ^ data_in[3];
                    p2 = data_in[1] ^ data_in[2] ^ data_in[3];
                    ecc_word = data_in[3:0];
                    ram_data[addr_val] <= data_in;
                    ram_ecc[addr_val] <= ecc_word;
                end
                'R: begin
                    // Read operation
                    addr_val = addr_b;
                    data_out <= ram_data[addr_val];
                    // Recompute parity
                    p0 = ram_data[addr_val][0] ^ ram_data[addr_val][1] ^ ram_data[addr_val][2];
                    p1 = ram_data[addr_val][0] ^ ram_data[addr_val][2] ^ ram_data[addr_val][3];
                    p2 = ram_data[addr_val][1] ^ ram_data[addr_val][2] ^ ram_data[addr_val][3];
                    ecc_word = {p0, p1, p2};
                    data_word = ram_data[addr_val];
                    if (ecc_word != ecc_word_original) begin
                        ecc_error <= 1;
                    end else begin
                        ecc_error <= 0;
                    end
                end
            endcase
        end
    end

endmodule
