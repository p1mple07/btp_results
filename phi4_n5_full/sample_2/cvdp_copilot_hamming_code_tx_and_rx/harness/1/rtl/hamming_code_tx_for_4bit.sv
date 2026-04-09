module hamming_code_tx_for_4bit(
    input  logic [3:0] data_in,
    output logic [7:0] data_out
);

    // Hamming code encoding for 4-bit data using 3 parity bits.
    // The 7-bit Hamming code (data_out[7:1]) is constructed as follows:
    // - data_out[0] is a redundant bit (always 0).
    // - data_out[1] is the parity bit for data_in bits at positions 0, 1, and 3.
    // - data_out[2] is the parity bit for data_in bits at positions 0, 2, and 3.
    // - data_out[3] holds data_in[0].
    // - data_out[4] is the parity bit for data_in bits at positions 1, 2, and 3.
    // - data_out[5] holds data_in[1].
    // - data_out[6] holds data_in[2].
    // - data_out[7] holds data_in[3].
    //
    // This encoding uses even parity (XOR of the specified bits).
    always_comb begin
        data_out[0] = 1'b0; // redundant bit
        
        // Parity bit for data_in[0], data_in[1], data_in[3]
        data_out[1] = data_in[0] ^ data_in[1] ^ data_in[3];
        
        // Parity bit for data_in[0], data_in[2], data_in[3]
        data_out[2] = data_in[0] ^ data_in[2] ^ data_in[3];
        
        // Data bit assignment
        data_out[3] = data_in[0];
        
        // Parity bit for data_in[1], data_in[2], data_in[3]
        data_out[4] = data_in[1] ^ data_in[2] ^ data_in[3];
        
        // Data bit assignment
        data_out[5] = data_in[1];
        
        // Data bit assignment
        data_out[6] = data_in[2];
        
        // Data bit assignment
        data_out[7] = data_in[3];
    end

endmodule