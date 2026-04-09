module neuromorphic_array #(
    parameter NEURONS = 8,       // Number of neurons
    parameter INPUTS  = 8,       // Number of inputs (unused in this design)
    parameter OUTPUTS = 8        // Number of outputs (unused in this design)
) (
    input  logic [7:0] ui_in,       // Control input (ui_in[0] used for update)
    input  logic [7:0] uio_in,      // Input data for the first neuron
    output logic [7:0] uo_out,      // Output from the last neuron
    input  logic clk,              // Clock signal
    input  logic rst_n             // Active-low reset signal
);
    // Internal wires to hold each neuron's output
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons in a generate loop.
    // The first neuron receives the external input (uio_in),
    // and each subsequent neuron receives the previous neuron's output.
    genvar i;
    generate
        for (i = 0; i < NEURONS; i = i + 1) begin : neuron_inst
            if (i == 0) begin
                single_neuron_dut neuron_inst(
                    .clk(clk),
                    .rst_n(rst_n),
                    .control(ui_in[0]),
                    .seq_in(uio_in),
                    .seq_out(neuron_outputs[i])
                );
            end else begin
                single_neuron_dut neuron_inst(
                    .clk(clk),
                    .rst_n(rst_n),
                    .control(ui_in[0]),
                    .seq_in(neuron_outputs[i-1]),
                    .seq_out(neuron_outputs[i])
                );
            end
        end
    endgenerate

    // The final output is taken from the last neuron in the array.
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule

module single_neuron_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic control,        // Control signal: 1 enables state update
    input  logic [7:0] seq_in,   // Input data for state update
    output logic [7:0] seq_out   // Output: current stored state
);
    // Internal state register for the neuron
    logic [7:0] state;

    // Sequential process: on rising clock edge, update state based on control signal.
    // Active-low reset clears the state to zero.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= 8'b0;
        else if (control)
            state <= seq_in;
        else
            state <= state;
    end

    // Drive the output with the current state.
    assign seq_out = state;

endmodule