module neuromorphic_array #(
    parameter NEURONS = 8,
    parameter INPUTS = 8,
    parameter OUTPUTS = 8
) (
    input  logic [7:0] ui_in,
    input logic [7:0] uio_in,
    output logic [7:0] uo_out,
    input logic clk,
    input logic rst_n
);

    logic [7:0] neuron_outputs [0 : NEURONS - 1];

    genvar i;
    generate
    for (int i = 0; i < NEURONS; i++) begin : neuron_inst
        single_neuron_dut uut (.clk(clk),
                              .rst_n(rst_n),
                              .control(ui_in[i]),
                              .seq_in(uio_in),
                              .seq_out(neuron_outputs[i]));
    end

    assign uo_out = neuron_outputs[NEURONS-1];

endgenerate

endmodule

module single_neuron_dut (
    input logic clk,
    input logic rst_n,
    input logic control,
    input logic [7:0] seq_in,
    output logic [7:0] seq_out
);

    reg [7:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 8'h0;
        end else begin
            if (control) begin
                state <= seq_in;
            end else begin
                state <= state;
            end
        end
    end

    assign seq_out = state;

endmodule
