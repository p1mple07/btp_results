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
    // Internal wires for neuron outputs
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons
    genvar i;
    generate
        for (genvar i=0; i < NEURONS; i++) begin : neuron_inst
            single_neuron_dut dut (#(INPUTS) ui_in, #(OUTPUTS) uio_in, #(CONTROL) control, #(SEQUENCE) seq_in, #(CLOCK) clk, #(RST) rst_n, neuron_outputs[i]);
        end
    endgenerate

    // Combine outputs from the last neuron
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule
