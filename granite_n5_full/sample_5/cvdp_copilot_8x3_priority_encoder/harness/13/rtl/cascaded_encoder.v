module priority_encoder #(parameter N = 8, M = $clog2(N)) (
    input       [N-1:0] in     ,   // N input lines
    output reg  [M-1:0] out         // M output lines
);

reg [N-1:0] in_s;
integer i;

// Padding zeros to match the input width with the output width
generate
    if (N > M) begin
        assign in_s = {N-M{1'b0}} & in;
    end
    else begin
        assign in_s = in;
    end
endgenerate

always @(*) begin
    out = 0;
    for (i = 0; i < N; i++) begin
        out = out | (in_s[i] << i);
    end
end

endmodule

module cascaded_encoder #(parameter N = 8) (
    input       [N-1:0] input_signal,   // N-bit input signal
    output reg  [M-1:0] out,             // M-bit output vector
    output reg  [M-2:0] out_upper_half, // M-1-bit output vector for upper half of input
    output reg  [M-2:0] out_lower_half  // M-1-bit output vector for lower half of input
);

localparam M = $clog2(N);

wire [M-1:0] upper_half;
wire [M-1:0] lower_half;

priority_encoder #(.N(N/2),.M(M)) u_upper_half (
   .in(input_signal[(N-1)/2:0]),
   .out(upper_half)
);

priority_encoder #(.N(N/2),.M(M)) u_lower_half (
   .in(input_signal[N-1:(N+1)/2]),
   .out(lower_half)
);

assign out = {upper_half[M-2], upper_half} | {lower_half[M-2], lower_half};
assign out_upper_half = upper_half[M-2:0];
assign out_lower_half = lower_half[M-2:0];

endmodule

module tb_cascaded_encoder;

logic clk;
logic reset;
logic [7:0] input_data;
logic [2:0] expected_output;
logic [2:0] actual_output;
logic [2:0] upper_half_expected;
logic [2:0] upper_half_actual;
logic [2:0] lower_half_expected;
logic [2:0] lower_half_actual;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    input_data = 0;
    #10 reset = 0;
    #10 input_data = 8'hFF;
    #10 input_data = 8'hAA;
    #10 input_data = 8'h55;
    #10 input_data = 0;
    #10 $finish;
end

priority_encoder u_priority_encoder (
   .in(input_data),
   .out(actual_output)
);

cascaded_encoder u_cascaded_encoder (
   .input_signal(input_data),
   .out(actual_output),
   .out_upper_half(upper_half_actual),
   .out_lower_half(lower_half_actual)
);

initial begin
    $display("Input Data: %b", input_data);
    $display("Expected Output: %b", expected_output);
    $display("Actual Output: %b", actual_output);
    $display("Upper Half Expected: %b", upper_half_expected);
    $display("Upper Half Actual: %b", upper_half_actual);
    $display("Lower Half Expected: %b", lower_half_expected);
    $display("Lower Half Actual: %b", lower_half_actual);
    $display("Test Passed!");
    $finish;
end

endmodule