module neuromorphic_array #(
    parameter NEURONS = 8,       // Number of neurons
    parameter INPUTS  = 8,        // Number of inputs
    parameter OUTPUTS = 8         // Number of outputs
) (
    input  logic [7:0] ui_in,       // Control input (ui_in[0] used for update)
    input  logic [7:0] uio_in,      // Input data
    output logic [7:0] uo_out,     // Output data from the last neuron
    input  logic clk,              // Clock signal
    input  logic rst_n             // Active-low reset
);
    // Internal wires for neuron outputs
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons in a generate loop
    genvar i;
    generate
        for (i = 0; i < NEURONS; i = i + 1) begin : neuron_inst
            if (i == 0) begin
                // First neuron: input is uio_in
                single_neuron_dut neuron (
                    .clk(clk),
                    .rst_n(rst_n),
                    .control(ui_in[0]),
                    .seq_in(uio_in),
                    .seq_out(neuron_outputs[i])
                );
            end else begin
                // Subsequent neurons: input is the output of the previous neuron
                single_neuron_dut neuron (
                    .clk(clk),
                    .rst_n(rst_n),
                    .control(ui_in[0]),
                    .seq_in(neuron_outputs[i-1]),
                    .seq_out(neuron_outputs[i])
                );
            end
        end
    endgenerate

    // Final output is taken from the last neuron in the array
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule

module single_neuron_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic control,        // Control signal: high enables state update
    input  logic [7:0] seq_in,   // Input data for updating state
    output logic [7:0] seq_out   // Output of the neuron (current state)
);
    // Internal state register
    logic [7:0] state;

    // Sequential process: on reset, clear state; otherwise update based on control signal
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

    // Assign the current state to the output
    assign seq_out = state;

endmodule