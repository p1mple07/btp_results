module rc5_enc_16bit(
    input wire clock,
    input wire reset,
    input wire enc_start,
    input wire [15:0] p,
    output reg [15:0] c,
    output wire enc_done
) {
    wire [7:0] q1, q2, q3, q4, q5, q6, q7, q8;
    
    // Initial state of the registers
    reg [7:0] A, B, S0, S1, S2, S3;
    reg [7:0] q1_reg, q2_reg, q3_reg, q4_reg, q5_reg, q6_reg, q7_reg, q8_reg;
    
    // Constants for the S-box
    const byte S[4][8] = {
        { 0x94, 0x15, 0x5E, 0x7A, 0x3D, 0x02, 0x3F, 0x5A },  // S0
        { 0x07, 0x81, 0x15, 0x55, 0x3F, 0x3D, 0x4F, 0x01 },  // S1
        { 0x55, 0x15, 0x05, 0x55, 0x73, 0x01, 0x88, 0x90 },  // S2
        { 0x7A, 0x55, 0x35, 0x01, 0x5E, 0x01, 0x2F, 0x9B }   // S3
    };
    
    // CA configuration
    reg [7:0] ca_in [8];
    ca_in[0] = A;
    ca_in[1] = B;
    ca_in[2] = B;
    ca_in[3] = B;
    ca_in[4] = B;
    ca_in[5] = B;
    ca_in[6] = B;
    ca_in[7] = B;
    
    // Evolution function for CA
    always @ (posedge clock || enc_start) begin
        if (reset) begin
            A = 8'h0;
            B = 8'h0;
            q1_reg = 8'hff;
            q2_reg = 8'hff;
            q3_reg = 8'hff;
            q4_reg = 8'hff;
            q5_reg = 8'hff;
            q6_reg = 8'hff;
            q7_reg = 8'hff;
            q8_reg = 8'hff;
            S0 = 8'h0;
            S1 = 8'h0;
            S2 = 8'h0;
            S3 = 8'h0;
            c = 8'h0;
            enc_done = 0;
        elsif enc_start == 1 begin
            // Load plaintext into A and B
            A = p[7:0];
            B = p[7:0];
            
            // Evolve the CA to generate S-box
            ca_in[0] = q1_reg;
            ca_in[1] = q2_reg;
            ca_in[2] = q3_reg;
            ca_in[3] = q4_reg;
            ca_in[4] = q5_reg;
            ca_in[5] = q6_reg;
            ca_in[6] = q7_reg;
            ca_in[7] = q8_reg;
            
            // Apply CA rules to compute next state
            q1_reg = q1_reg_next();
            q2_reg = q2_reg_next();
            q3_reg = q3_reg_next();
            q4_reg = q4_reg_next();
            q5_reg = q5_reg_next();
            q6_reg = q6_reg_next();
            q7_reg = q7_reg_next();
            q8_reg = q8_reg_next();
        end
    end
    
    // Extract S-box values from CA state
    S0 = q1_reg;
    S1 = q2_reg;
    S2 = q3_reg;
    S3 = q4_reg;
    
    // Encryption steps
    // Step 1: Add S0 and S1 to A and B
    A = (A + S0) % 256;
    B = (B + S1) % 256;
    
    // Step 2: One round of Feistel transformation
    // Compute intermediate values
    local reg x, y;
    x = ((A XOR B) << B) + S2;
    y = ((B XOR A) << A) + S3;
    
    // Assign back to A and B
    A = x % 256;
    B = y % 256;
    
    // Combine A and B into ciphertext
    c = (A << 8) | B;
    
    // Set done flag
    enc_done = 1;
}

// Helper functions for CA evolution
function q1_reg_next() {
    q1_reg = q6_reg;
    return (q6_reg ^ q5_reg ^ q4_reg ^ q3_reg ^ q2_reg ^ q1_reg ^ q0_reg);
}
function q2_reg_next() {
    q2_reg = q7_reg ^ q5_reg;
    return (q7_reg ^ q5_reg) & ~(q2_reg);
}
function q3_reg_next() {
    q3_reg = q6_reg ^ q5_reg ^ q4_reg;
    return (q6_reg ^ q5_reg ^ q4_reg);
}
function q4_reg_next() {
    q4_reg = q5_reg ^ q3_reg;
    return (q5_reg ^ q3_reg);
}
function q5_reg_next() {
    q5_reg = q4_reg ^ q2_reg;
    return (q4_reg ^ q2_reg);
}
function q6_reg_next() {
    q6_reg = q3_reg ^ q1_reg;
    return (q3_reg ^ q1_reg);
}
function q7_reg_next() {
    q7_reg = q2_reg ^ q0_reg;
    return (q2_reg ^ q0_reg);
}
function q8_reg_next() {
    q8_reg = q7_reg ^ q5_reg;
    return (q7_reg ^ q5_reg);
}