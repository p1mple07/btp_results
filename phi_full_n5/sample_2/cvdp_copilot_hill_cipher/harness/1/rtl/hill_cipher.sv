module hill_cipher(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [14:0] plaintext,
    input wire [44:0] key,
    output reg [14:0] ciphertext,
    output reg done
);

    reg [3:0] key_reg[0:2];
    reg [3:0] plaintext_reg[0:2];
    reg [14:0] ciphertext_reg[0:2];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            key_reg <= {4'b0, 4'b0, 4'b0};
            plaintext_reg <= {4'b0, 4'b0, 4'b0};
            ciphertext_reg <= {4'b0, 4'b0, 4'b0};
        end else if (start) begin
            key_reg[0] = key[39:35];
            key_reg[1] = key[34:30];
            key_reg[2] = key[29:25];
            plaintext_reg[0] = plaintext[14:10];
            plaintext_reg[1] = plaintext[9:5];
            plaintext_reg[2] = plaintext[4:0];

            for (i = 0; i < 3; i = i + 1) begin
                ciphertext_reg[i] = (key_reg[0][i] * plaintext_reg[0] + key_reg[1][i] * plaintext_reg[1] + key_reg[2][i] * plaintext_reg[2]) mod 26;
            end

            ciphertext <= ciphertext_reg[2] << 12 | ciphertext_reg[1] << 7 | ciphertext_reg[0];
            done = 1;
        end
    end

endmodule
