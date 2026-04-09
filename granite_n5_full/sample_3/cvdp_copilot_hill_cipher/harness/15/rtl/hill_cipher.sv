module hill_cipher (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [14:0] plaintext,   // 3 letters, 5 bits each
    input logic [44:0] key,         // 9 elements, 5 bits each
    output logic [14:0] ciphertext, // 3 letters, 5 bits each 
    output logic done
);

    //... (code omitted for brevity)

    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule