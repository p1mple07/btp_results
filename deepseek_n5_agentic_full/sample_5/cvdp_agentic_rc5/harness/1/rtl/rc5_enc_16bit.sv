module rc5_enc_16bit(
    input clock,
    input reset,
    input enc_start,
    input p,
    output c,
    output enc_done
)

parameter seed = 8'hff;
parameter s0 = 8'h20;
parameter s1 = 8'h10;
parameter s2 = 8'hff;
parameter s3 = 8'hff;

wire [7:0] a, b;
wire q1, q2, q3, q4, q5, q6, q7, q8;

// Initialize S-box values using CA_1
insta ca_1(.clock(clock), .reset(reset), .ca_seed(seed), .output_reg [7:0] s_array);
 insta_ca_1.s0 = s_array[0];
 insta_ca_1.s1 = s_array[1];
 insta_ca_1.s2 = s_array[2];
 insta_ca_1.s3 = s_array[3];

// Perform RC5 encryption with one round
always_ff @posedge clock
begin
    if (reset) begin
        a = p;
        b = 0;
        c = 0;
        enc_done = 0;
    else begin
        if (enc_start) begin
            a = (a + s0) % 256;
            b = (b + s1) % 256;
            
            // First iteration of RC5 round
            q1 = a ^ b;
            q2 = (a >> 1) ^ (b >> 1);
            q3 = a ^ (~b);
            q4 = (a ^ b) << 8'h0f;
            q5 = (a ^ ~b) << 8'h0e;
            q6 = (a ^ (b >> 1)) << 8'h0d;
            q7 = (a ^ (b << 1)) << 8'h0c;
            q8 = (a ^ (b << 1)) << 8'h0b;
            
            a = (q1 ^ (q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8)) % 256;
            b = (q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8) % 256;
            
            c = (a << 8) | b;
            enc_done = 1;
        end
    end
end
endmodule