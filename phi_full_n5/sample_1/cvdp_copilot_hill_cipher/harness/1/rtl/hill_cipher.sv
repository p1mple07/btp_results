module hill_cipher #(parameter BLOCK_SIZE = 3, KEY_BITS = 5) (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [14:0] plaintext,
    input wire [44:0] key,
    output reg [14:0] ciphertext,
    output reg done
);

// Define the key matrix size based on KEY_BITS
parameter K_SIZE = BLOCK_SIZE * KEY_BITS / 8;

// State register
reg [K_SIZE - 1:0] state;

// Local variables
wire [K_SIZE - 1:0] key_matrix[0:K_SIZE-1];
wire [BLOCK_SIZE - 1:0] plaintext_vector[0:K_SIZE-1];
wire [BLOCK_SIZE - 1:0] ciphertext_vector[0:K_SIZE-1];

// Key matrix initialization
initial begin
    key_matrix[0] = {key[44-1:44], key[40-1:40], key[35-1:35]};
    key_matrix[1] = {key[39-1:39], key[35-1:35], key[30-1:30]};
    key_matrix[2] = {key[34-1:34], key[29-1:29], key[24-1:24]};
end

// Plaintext to vector conversion
always @(posedge clk) begin
    if (reset) begin
        state <= 0;
        ciphertext <= 0;
        done <= 0;
    end else if (start) begin
        plaintext_vector[0] = {plaintext[14-1:8], plaintext[9-1:4], plaintext[4-1:0]};
        if (state == 0) begin
            ciphertext <= ciphertext_vector;
            state <= 1;
        end
    end
end

// Matrix multiplication with modular arithmetic
always @(posedge clk) begin
    if (state == 1) begin
        for (int i = 0; i < BLOCK_SIZE; i++) begin
            ciphertext_vector[i] = (key_matrix[0][i] * plaintext_vector[0] +
                                   key_matrix[1][i] * plaintext_vector[1] +
                                   key_matrix[2][i] * plaintext_vector[2]) mod 26;
        end
        state <= 2;
    end
end

// Convert ciphertext vector to block and map to letters
always @(posedge clk) begin
    if (state == 2) begin
        ciphertext = ciphertext_vector;
        done <= 1;
    end
end

endmodule
