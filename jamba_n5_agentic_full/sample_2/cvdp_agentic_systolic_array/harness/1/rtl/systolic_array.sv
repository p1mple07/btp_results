module systolic_array (
    input wire clk,
    input wire reset,
    output reg [DATA_WIDTH-1:0] y0,
    output reg [DATA_WIDTH-1:0] y1
);

    // Instantiate four weight_stationary_pe PEs
    weight_stationary_pe u0 (
        .clk(clk),
        .reset(reset),
        .data_width(DATA_WIDTH),
        .input_in(u1.input.input_in),
        .weight(u0.output.psum_out),
        .psum_out(u1.output.psum_out),
        .input_out(u1.input.input_in),
        .psum_in(u0.output.psum_in)
    );

    weight_stationary_pe u1 (
        .clk(clk),
        .reset(reset),
        .data_width(DATA_WIDTH),
        .input_in(u0.output.input_in),
        .weight(u1.output.psum_out),
        .psum_out(u0.output.psum_out),
        .input_out(u1.input.input_in),
        .psum_in(u0.output.psum_in)
    );

    weight_stationary_pe u2 (
        .clk(clk),
        .reset(reset),
        .data_width(DATA_WIDTH),
        .input_in(u2.output.input_in),
        .weight(u0.output.psum_out),
        .psum_out(u2.output.psum_out),
        .input_out(u2.input.input_in),
        .psum_in(u1.output.psum_in)
    );

    weight_stationary_pe u3 (
        .clk(clk),
        .reset(reset),
        .data_width(DATA_WIDTH),
        .input_in(u1.output.input_in),
        .weight(u2.output.psum_out),
        .psum_out(u1.output.psum_out),
        .input_out(u3.input.input_in),
        .psum_in(u2.output.psum_in)
    );

    // Now read outputs from the PEs
    assign y0 = u0.output.input_out;
    assign y1 = u0.output.psum_out;

endmodule
