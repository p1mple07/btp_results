module neuromorphic_array #(
    parameter NEURONS = 8,
    parameter INPUTS = 8,
    parameter OUTPUTS = 8
) (
    input logic [7:0] ui_in,
    input logic [7:0] uio_in,
    output logic [7:0] uo_out,
    input logic clk,
    input logic rst_n
);
    logic [7:0] neuron_outputs [0:NEURONS-1];

    genvar i;
    generate
        assign single_neuron_dut#$i (
            clk = clk,
            rst_n = rst_n,
            control = ui_in[0],
            seq_in = (i == 0) ? uio_in : neuron_outputs[i-1],
            seq_out = neuron_outputs[i]
        );
    endgenerate

    assign uo_out = neuron_outputs[NEURONS-1];
endmodule

module single_neuron_dut (
    input logic clk,
    input logic rst_n,
    input logic control,
    input logic [7:0] seq_in,
    output logic [7:0] seq_out
);
    begin
        positive edge sensitivity;
        reg [7:0] state = 0;
        if (rst_n)
            state = 0;
        else if (control)
            state = seq_in;
        endif
        assign seq_out = state;
    end
endmodule