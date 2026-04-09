module hill_cipher #(parameter BLOCK_SIZE = 3) (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [14:0] plaintext,
    input wire [44:0] key,
    output reg [14:0] ciphertext
);

    // State register for FSM
    reg [2:0] state, done;

    // Local variables for matrix multiplication
    reg [4:0] temp[0:BLOCK_SIZE-1];

    // Modulo operation
    reg [5:0] mod26;

    // Encryption process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            ciphertext <= 0;
            done <= 0;
        end else if (start) begin
            state <= 1;
        end else if (state == 1) begin
            // Perform matrix multiplication
            temp[0] <= key[4*0 +: BLOCK_SIZE] * plaintext[0];
            temp[1] <= key[4*1 +: BLOCK_SIZE] * plaintext[1];
            temp[2] <= key[4*2 +: BLOCK_SIZE] * plaintext[2];

            // Apply modulo 26
            mod26 <= temp[0] + temp[1] + temp[2];
            mod26 <= mod26 % 32'h26;

            // Store results
            ciphertext <= {mod26, mod26, mod26};
            done <= 1;
        end
    end

endmodule
