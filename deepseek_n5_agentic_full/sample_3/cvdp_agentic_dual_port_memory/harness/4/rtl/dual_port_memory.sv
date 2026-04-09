module dual_port_memory #(
    parameter DATA_WIDTH = 4,  // Data width (excluding ECC)
    parameter ECC_WIDTH = 3,    // ECC width
    parameter ADDR_WIDTH = 5,  // Address width
    parameter MEM_DEPTH = (1 << ADDR_WIDTH)  // Explicit memory depth
)(
    input clk,
    input rst_n,                         // Active-low synchronous reset
    input we,                           // Write enable 
    input [ADDR_WIDTH-1:0] addr_a,        // Address for port A
    input [ADDR_WIDTH-1:0] addr_b,        // Address for port B
    input [DATA_WIDTH-1:0] data_in,     // Data input 
    output reg [DATA_WIDTH-1:0] data_out, // Data output for port A
);

    // Define combined memory with ECC encoding
    reg [7-1:0] ram [MEM_DEPTH-1:0];  // 7-bit memory cells including ECC
    
    // Helper function to extract data and ECC parts
    function bitvector extract_ecc (bitvec data);
        reg [3-1:0] ecc;
        assign ecc = (data >> 4) & 3;
        return ecc;
    endfunction

    function bitvector extract_data (bitvec data);
        reg [4-1:0] dataword;
        assign dataword = data & 15;
        return dataword;
    endfunction

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
        else begin
            if (we) begin
                // Encode data_in into 7-bit word with ECC
                bitvector full_word;
                full_word = (data_in << 4) | ecc_error; // ECC will be computed later
                
                ram[addr_a] <= full_word;
                
                // Compute ECC here when we=1
                // Note: ecc_error will be updated later
            end else begin
                // ECC decoding happens during readback
                // Note: ecc_error is not set during normal operations
            end
        end
    end

    // ECC calculation functions inside the module
    // These can be moved to a separate module in real implementation
    // Function to compute ECC from data
    function bitvector compute_ecc (bitvec dataword);
        reg [3-1:0] p0, p1, p2;
        p0 = dataword[3] ^ dataword[2] ^ dataword[0];
        p1 = dataword[3] ^ dataword[1] ^ dataword[0];
        p2 = dataword[2] ^ dataword[1] ^ dataword[0];
        return (p0 << 2) | (p1 << 1) | p2;
    endfunction

    // ... rest of the code ...
    
    // Now actually implement the read operation
    if (rst_n == 0) begin
        data_out <= 0;
        ecc_error <= 0;
    end else begin
        if (addr_b != addr_a) begin  // Collision handled externally
            // Read from memory
            bitvector full_word;
            full_word = ram[addr_b];
            
            // Extract data and ECC
            bitvector dataword = extract_data(full_word);
            bitvector ecc_word = extract_ecc(full_word);
            
            // Recompute ECC from dataword
            bitvector computed_ecc = compute_ecc(dataword);
            
            // XOR with stored ECC to get syndrome
            bitvector syndrome = ecc_word ^ computed_ecc;
            
            // Update ecc_error based on syndrome
            ecc_error <= syndrome;
            
            // Pass through uncorrected data
            data_out <= dataword;
        end else begin
            data_out <= ram[addr_b];  // Not needed since addr_b != addr_a is assumed
        end
    end
endmodule