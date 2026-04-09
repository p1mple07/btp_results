module hill_cipher (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [14:0] plaintext,
    input wire [44:0] key,
    output reg [14:0] ciphertext,
    output reg done
);

    // Define constants
    localparam MOD = 26;
    
    // State registers
    reg [14:0] state_vector [0:2];
    
    // Initialization
    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state_vector <= {2'b0, 2'b0, 2'b0};
            ciphertext <= 15'b0;
            done <= 0;
        end else if (start) begin
            state_vector <= {plaintext[13:8], plaintext[7:4], plaintext[3:0]};
            ciphertext <= 15'b0;
            done <= 0;
        end
    end
    
    // Matrix multiplication and modular arithmetic
    always @ (posedge clk) begin
        if (done) begin
            ciphertext <= state_vector[0] + state_vector[1] * key[3*0 +: 5] + state_vector[2] * key[3*1 +: 5] + key[3*2 +: 5] mod MOD;
            done <= 1;
        end
    end
    
    // Convert ciphertext back to letters
    always @ (posedge clk) begin
        if (done) begin
            ciphertext[13:8] = ciphertext[14:0] / 5;
            ciphertext[7:4] = ciphertext[15:10] / 5;
            ciphertext[3:0] = ciphertext[11:6] / 5;
        end
    end

endmodule
