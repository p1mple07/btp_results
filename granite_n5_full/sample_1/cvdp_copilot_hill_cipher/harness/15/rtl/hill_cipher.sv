module hill_cipher (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [14:0] plaintext,
    input logic [44:0] key,
    output logic [14:0] ciphertext,
    output logic done
);

    //... (rest of the original module)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            temp0 <= 12'b0;
            temp1 <= 12'b0;
            temp2 <= 12'b0;
            C0_reg <= 5'b0;
            C1_reg <= 5'b0;
            C2_reg <= 5'b0;
        end
        else begin
            case (current_state)
                COMPUTE: begin
                    temp0 <= ({5{plaintext[14]}} * key[44:40]) % 26 + ({5{plaintext[9]}} * key[39:35]) % 26 + ({5{plaintext[4]}} * key[34:30]);
                    temp1 <= ({5{plaintext[14]}} * key[29:25]) % 26 + ({5{plaintext[9]}} * key[24:20]) % 26 + ({5{plaintext[4]}} * key[19:15]);
                    temp2 <= ({5{plaintext[14]}} * key[14:10]) % 26 + ({5{plaintext[9]}} * key[9:5]) % 26 + ({5{plaintext[4]}} * key[4:0]);
                end
                COMPUTE_MOD: begin
                    C0_reg <= temp0 % 26;
                    C1_reg <= temp1 % 26;
                    C2_reg <= temp2 % 26;
                end
                default: begin
                    temp0 <= 12'b0;
                    temp1 <= 12'b0;
                    temp2 <= 12'b0;
                    C0_reg <= 5'b0;
                    C1_reg <= 5'b0;
                    C2_reg <= 5'b0;
                end
            endcase
        end
    end

    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule