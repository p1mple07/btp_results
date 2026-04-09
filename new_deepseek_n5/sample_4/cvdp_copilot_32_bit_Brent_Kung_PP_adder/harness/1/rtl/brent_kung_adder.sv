module brent_kung_adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic carry_in,
    output logic [31:0] sum,
    output logic carry_out
);

    logic [31:0] P1, G1;
    logic [15:0] C;
    generate
        P1 = a ^ b;
        G1 = a & b;
    endgenerate
    generate
        for(i=0; i<=30; i=i+2) begin: integer;
            assign G2[i/2] = G1[0] | P1[0];
            assign P2[i/2] = P1[0] & P1[0];
        end
    endgenerate
    
    generate
        for(i=0; i<=14; i=i+2) begin: integer;
            assign G3[i/2] = G2[i+1] | (P2[i+1] & G2[i]);
            assign P3[i/2] = P2[i+1] & P2[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=6; i=i+2) begin: integer;
            assign G4[i/2] = G3[i+1] | (P3[i+1] & G3[i]);
            assign P4[i/2] = P3[i+1] & P3[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=2; i=i+2) begin: integer;
            assign G5[i/2] = G4[i+1] | (P4[i+1] & G4[i]);
            assign P5[i/2] = P4[i+1] & P4[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=1; i=i+2) begin: integer;
            assign G6[i/2] = G5[i+1] | (P5[i+1] & G5[i]);
            assign P6[i/2] = P5[i+1] & P5[i];
        end
    endgenerate
    
    assign
        C[1] = G1[0] | (P1[0] & carry_in);
        C[2] = G2[0] | (P2[0] & C[1]);
        C[4] = G3[0] | (P3[0] & C[2]);
        C[8] = G4[0] | (P4[0] & C[4]);
        C[16] = G5[0] | (P5[0] & C[8]);
        C[31] = G6 | (P6 & C[16]);
    
    assign sum = P1 | {C[31:1], carry_in};
    assign carry_out = C[31];
    
endmodule