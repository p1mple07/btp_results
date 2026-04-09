
module swizzler #(
    parameter int N = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic [N-1:0] data_in,
    input  logic [N*($clog2(N+1))-1:0] mapping_in,
    input  logic config_in,
    input  logic [2:0] operation_mode,
    output logic [N-1:0] data_out,
    output logic error_flag
);
