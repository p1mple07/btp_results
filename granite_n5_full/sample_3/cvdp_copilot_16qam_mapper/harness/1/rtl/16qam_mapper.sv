module qam16_mapper_interpolated #(
    parameter int unsigned N = 4, // Number of input symbols
    parameter int unsigned IN_WIDTH = 4, // Bit width of each input symbol
    parameter int unsigned OUT_WIDTH = 3 // Bit width of the output components
) (
    input logic [N*IN_WIDTH-1:0] bits, // Packed input bits
    output logic [(N+N/2)*OUT_WIDTH-1:0] I, // Packed output of real (I) components
    output logic [(N+N/2)*OUT_WIDTH-1:0] Q // Packed output of imaginary (Q) components
);

// Your implementation here...

endmodule