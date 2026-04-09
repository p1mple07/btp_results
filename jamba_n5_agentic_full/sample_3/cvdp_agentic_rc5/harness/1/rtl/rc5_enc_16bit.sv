module rc5_enc_16bit (
    input wire clock,
    input wire reset,
    input wire enc_start,
    input wire [15:0] p,
    output reg [7:0] c
);

    reg [7:0] ca_seed;
    reg [7:0] s0, s1, s2, s3, s4, s5, s6, s7;
    reg [7:0] ca_out[8];
    reg reset_n;

    initial begin
        ca_seed = 8'b00000000;
    end

    always_ff @(posedge clock) begin
        if (reset)
            ca_seed <= 8'b11111111;
        else
            // Apply Rule 90 and Rule 150
            s0 = ca_seed[0] ^ ca_seed[7];
            s1 = ca_seed[1] ^ ca_seed[0] ^ ca_seed[1] ^ ca_seed[6];
            s2 = ca_seed[2] ^ ca_seed[1] ^ ca_seed[2] ^ ca_seed[7];
            s3 = ca_seed[3] ^ ca_seed[2] ^ ca_seed[3] ^ ca_seed[4];
            s4 = ca_seed[4] ^ ca_seed[3] ^ ca_seed[4] ^ ca_seed[5];
            s5 = ca_seed[5] ^ ca_seed[4] ^ ca_seed[5] ^ ca_seed[6];
            s6 = ca_seed[6] ^ ca_seed[5] ^ ca_seed[6] ^ ca_seed[7];
            s7 = ca_seed[7] ^ ca_seed[6] ^ ca_seed[7] ^ ca_seed[0];
            ca_seed = s0;
        end

        c = {s0, s1, s2, s3, s4, s5, s6, s7};
    end

endmodule
