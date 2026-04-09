
reg signed [31:0] partial_products [0:7];
reg signed [15:0] X_reg, Y_reg;
reg [4:0] valid_reg; // Extended valid register for more granular state control

integer i;

// Registers for pipelining the addition stages
reg signed [31:0] s1, s2, s3, s4;
reg signed [31:0] temp_products1, temp_products2;
