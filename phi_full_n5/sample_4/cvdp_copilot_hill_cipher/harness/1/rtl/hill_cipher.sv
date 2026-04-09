module hill_cipher(
    input clk,
    input reset,
    input start,
    input [14:0] plaintext,
    input [44:0] key,
    output reg [14:0] ciphertext,
    output reg done
);
    // State variables
    reg [3:0] state = 4'd0; // 0: idle, 1: processing
    reg [4:0] temp_key[3:0];
    reg [14:0] temp_plaintext[3:0];

    // Function to perform modulo 26
    function [4:0] mod26(input [4:0] value);
        mod26 = value % 26;
    endfunction

    // Function to perform matrix multiplication
    function [4:0] matrix_mult(input [4:0] a, input [4:0] b);
        matrix_mult = a * b;
    endfunction

    // Encryption process
    always @(posedge clk) begin
        if (reset) begin
            state <= 4'd0;
            ciphertext <= 15'b0;
            done <= 1'b0;
        end else if (start) begin
            if (state == 4'd1) begin
                temp_key[0] = key[39:35];
                temp_key[1] = key[34:30];
                temp_key[2] = key[29:25];

                temp_plaintext[0] = plaintext[14:10];
                temp_plaintext[1] = plaintext[9:5];
                temp_plaintext[2] = plaintext[4:0];

                ciphertext[0] = mod26(matrix_mult(temp_key[0], temp_plaintext[0]));
                ciphertext[1] = mod26(matrix_mult(temp_key[0], temp_plaintext[1]));
                ciphertext[2] = mod26(matrix_mult(temp_key[0], temp_plaintext[2]));

                state <= 4'd2;
            end
        end

        if (state == 4'd2) begin
            ciphertext[0] = mod26(matrix_mult(temp_key[1], temp_plaintext[0]));
            ciphertext[1] = mod26(matrix_mult(temp_key[1], temp_plaintext[1]));
            ciphertext[2] = mod26(matrix_mult(temp_key[1], temp_plaintext[2]));

            state <= 4'd3;
        end

        if (state == 4'd3) begin
            ciphertext[0] = mod26(matrix_mult(temp_key[2], temp_plaintext[0]));
            ciphertext[1] = mod26(matrix_mult(temp_key[2], temp_plaintext[1]));
            ciphertext[2] = mod26(matrix_mult(temp_key[2], temp_plaintext[2]));

            state <= 4'd4;
        end

        if (state == 4'd4) begin
            done <= 1;
            state <= 4'd0;
        end
    end
endmodule
