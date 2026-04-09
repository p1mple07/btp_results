module square_root_seq(
    parameter WIDTH = 16
)(
    input logic [WIDTH-1:0] num,
    input logic clk,
    input logic rst,
    input logic start,
    output logic [WIDTH/2-1:0] final_root,
    output logic done
);

    //... (rest of the code)

endmodule