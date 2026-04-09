module hill_cipher (
    input wire [14:0] plaintext,
    input wire [44:0] key,
    input wire clock,
    input wire reset,
    output reg [14:0] ciphertext,
    output reg done
);

    // Finite State Machine states
    reg [2:0] state;

    // Key matrix storage
    reg [2][3] key_matrix;

    // Plaintext vector storage
    reg [4:0] plain_vec;

    // Ciphertext vector storage
    reg [4:0] cipher_vec;

    // Bit manipulation logic
    always @posedge clock begin
        if (reset) begin
            state = 0;
            done = 0;
        end else if (state == 0) begin
            // Initialization
            state = 1;
        end else if (state == 1) begin
            // Plaintext processing
            plain_vec = plaintext[14:0];
            state = 2;
        end else if (state == 2) begin
            // Key matrix processing
            key_matrix[0][0] = key[44:40];
            key_matrix[0][1] = key[43:39];
            key_matrix[0][2] = key[42:38];
            
            key_matrix[1][0] = key[39:35];
            key_matrix[1][1] = key[38:34];
            key_matrix[1][2] = key[37:33];
            
            key_matrix[2][0] = key[32:28];
            key_matrix[2][1] = key[31:27];
            key_matrix[2][2] = key[30:26];
            
            // Matrix multiplication
            cipher_vec[4] = (key_matrix[0][0] * plain_vec[4] + 
                             key_matrix[1][0] * plain_vec[3] + 
                             key_matrix[2][0] * plain_vec[2]) % 26;
            
            cipher_vec[3] = (key_matrix[0][1] * plain_vec[4] + 
                             key_matrix[1][1] * plain_vec[3] + 
                             key_matrix[2][1] * plain_vec[2]) % 26;
            
            cipher_vec[2] = (key_matrix[0][2] * plain_vec[4] + 
                             key_matrix[1][2] * plain_vec[3] + 
                             key_matrix[2][2] * plain_vec[2]) % 26;
            
            // Update state
            state = 3;
        end else if (state == 3) begin
            // Output ciphertext
            ciphertext = (cipher_vec[4] << 10) | (cipher_vec[3] << 5) | cipher_vec[2];
            done = 1;
            state = 0;
        end
    end
end

// Module initialization
initial begin
    // Set done to 1 initially
    done = 1;
end