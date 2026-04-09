brent_kung_adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic carry_in,
    output logic [31:0] sum,
    output logic carry_out
);
    logic [31:0] P1, G1;
    logic [15:0] C;
    logic [7:0] G2, P2;
    logic [3:0] G3, P3;
    logic [1:0] G4, P4;
    logic G5, P5;
    logic G6, P6;
    
    assign P1 = a ^ b;
    assign G1 = a & b;
    
    genvar i;
    generate
        for(i=0; i<=30; i=i+2) begin: second_stage  
            assign G2[i/2] = G1[0] | P1[0]; 
            assign P2[i/2] = P1[0] & P1[0];
        end
    endgenerate
        
    generate
        for(i=0; i<=14; i=i+2) begin: third_stage   
            assign G3[i/2] = G2[i+1] | (P2[i+1] & G2[i]);
            assign P3[i/2] = P2[i+1] & P2[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=6; i=i+2) begin: fourth_stage  
            assign G4[i/2] = G3[i+1] | (P3[i+1] & G3[i]);
            assign P4[i/2] = P3[i+1] & P3[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=2; i=i+2) begin: fifth_stage  
            assign G5[i/2] = G4[i+1] | (P4[i+1] & G4[i]);
            assign P5[i/2] = P4[i+1] & P4[i];
        end
    endgenerate
    
    generate
        for(i=0; i<=1; i=i+2) begin: sixth_stage  
            assign G6 = G5[1] | (P5[1] & G5[0]);
            assign P6 = P5[1] & P5[0];
        end
    endgenerate
    
    assign C[1] = G1[0] | (P1[0] & carry_in);
    assign C[2] = G1[2] | (P1[2] & C[1]);
    assign C[4] = G1[4] | (P1[4] & C[3]);
    assign C[8] = G1[8] | (P1[8] & C[7]);
    assign C[16] = G1[16] | (P1[16] & C[15]);
    assign C[32] = G6 | (P6 & carry_in);
    
    assign sum = P1 | {C[31:1], carry_in};
    assign carry_out = C[32];
    
endmodule