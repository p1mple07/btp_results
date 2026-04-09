`timescale 1ns/1ns

module systolic_array (
    input wire clk,
    input wire reset,
    input wire load_weights,
    input wire start,
    output reg [DATA_WIDTH-1:0] out_data,
    output reg [DATA_WIDTH-1:0] out_acc
);

    // Instantiate four PEs
    weight_stationary_pe PE0 (.clk(clk), .reset(reset), .load_weights(load_weights), .start(start), .done(done));
    weight_stationary_pe PE1 (.clk(clk), .reset(reset), .load_weights(load_weights), .start(start), .done(done));
    weight_stationary_pe PE2 (.clk(clk), .reset(reset), .load_weights(load_weights), .start(start), .done(done));
    weight_stationary_pe PE3 (.clk(clk), .reset(reset), .load_weights(load_weights), .start(start), .done(done));

    // Connections: 2x2 grid
    assign PE0.input_out = PE1.input_in;
    assign PE1.input_out = PE2.input_in;
    assign PE2.input_out = PE3.input_in;
    assign PE3.input_out = PE0.input_in;

    assign PE0.output_in = PE1.output_out;
    assign PE1.output_in = PE2.output_out;
    assign PE2.output_in = PE3.output_out;
    assign PE3.output_in = PE0.output_out;

    assign out_data = PE0.input_out;
    assign out_acc = PE0.psum_out;
    assign out_data2 = PE1.input_out;
    assign out_acc2 = PE1.psum_out;
    assign out_data3 = PE2.input_out;
    assign out_acc3 = PE2.psum_out;
    assign out_data4 = PE3.input_out;
    assign out_acc4 = PE3.psum_out;

endmodule
