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
    always @(*) begin
        for (genvar i=0; i < NEURONS; i=i+1) begin: neuron_inst
            instantiatable_neuron neuron(ui_in, uio_in, neuron_outputs[i], clk, rst_n);
        end
    end
    endgenerate

    // Combine outputs from the last neuron
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule
