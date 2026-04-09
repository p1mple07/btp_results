module neuromorphic_array #(
    parameter NEURONS = 8,       // Number of neurons
    parameter INPUTS  = 8,       // Number of inputs
    parameter OUTPUTS = 8        // Number of outputs
) (
    input  logic [7:0] ui_in,       // Control input (ui_in[0] is used)
    input  logic [7:0] uio_in,      // Input data for the first neuron
    output logic [7:0] uo_out,      // Output data from the last neuron
    input  logic clk,              // Clock signal
    input  logic rst_n             // Active-low reset
);
    // Internal wires for neuron outputs
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons in a generate loop
    genvar i;
    generate
        for (i = 0; i < NEURONS; i = i + 1) begin : neuron_inst
            // Local wire for each neuron's input
            wire [7:0] neuron_input;
            // For the first neuron, use uio_in; for subsequent neurons, use the previous neuron's output
            assign neuron_input = (i == 0) ? uio_in : neuron_outputs[i-1];

            // Instantiate single_neuron_dut for each neuron
            single_neuron_dut neuron (
                .clk(clk),
                .rst_n(rst_n),
                .control(ui_in[0]),
                .seq_in(neuron_input),
                .seq_out(neuron_outputs[i])
            );
        end
    endgenerate

    // The final output is derived from the last neuron's stored state
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule

module single_neuron_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic control,        // Control signal
    input  logic [7:0] seq_in,   // Input sequence
    output logic [7:0] seq_out   // Output sequence
);
    // Internal register to store the neuron state
    logic [7:0] state;

    // Sequential process for updating the neuron state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 8'b0;
        end else begin
            if (control)
                state <= seq_in;
            else
                state <= state;
        end
    end

    // Output the stored state
    assign seq_out = state;
endmodule