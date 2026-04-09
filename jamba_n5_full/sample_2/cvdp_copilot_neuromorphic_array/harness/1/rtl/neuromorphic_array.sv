module neuromorphic_array #(
    parameter NEURONS = 8,
    parameter INPUTS = 8,
    parameter OUTPUTS = 8
) (
    input  logic [7:0] ui_in,       // Control signal, where ui_in[0] determines if neurons update their state.
    input logic [7:0] uio_in,      // Input data fed into the neurons.
    output logic [7:0] uo_out,     // Output data
    input logic clk,                // Clock signal driving the module.
    input logic rst_n               // Active-low reset, initializing all neuron states when low.
);

    // Internal wires for neuron outputs
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons
    genvar i;
    generate
    for (genvar i=0; i < NEURONS; i++) begin : neuron_inst
        single_neuron_dut #(
            .CLK(clk),
            .RSTN(rst_n),
            .CONTROL(ui_in[0]),
            .SEQ_IN(uio_in),
            .SEQ_OUT(neuron_outputs[i])
        ) inst($nextstate);
    endgenerate

    // Combine outputs from the last neuron
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule

module single_neuron_dut (
    input logic clk,
    input logic rst_n,
    input logic control,        // Control signal
    input logic [7:0] seq_in,   // Input sequence
    output logic [7:0] seq_out   // Output sequence
);

    // Local variables, no computation needed, just output on seq_out.
endmodule
