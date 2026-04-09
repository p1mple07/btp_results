module cic_decimator #(
    // Parameters
    parameter int WIDTH = 16,
    parameter int RMAX = 2,
    parameter int M = 1,
    parameter int N = 2,
    
    // Registers
    localparam int REG_WIDTH = WIDTH + $clog2((RMAX * M)**N);
    
)(
    // Input Ports
    input wire clk,
    input wire rst,
    input wire input_tvalid,
    input wire [WIDTH-1:0] input_tdata,
    input wire [($clog2(RMAX)-1):0] rate,
    
    // Output Ports
    output logic output_tvalid,
    output logic [REG_WIDTH-1:0] output_tdata,
    output wire output_tready
);

// Implement the CIC Decimator module here

endmodule