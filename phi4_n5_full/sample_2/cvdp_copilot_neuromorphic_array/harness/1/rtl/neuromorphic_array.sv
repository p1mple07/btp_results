module neuromorphic_array #(
    parameter NEURONS = 8,       // Number of neurons
    parameter INPUTS  = 8,       // Number of inputs
    parameter OUTPUTS = 8        // Number of outputs
) (
    input  logic [7:0] ui_in,      // Control input (ui_in[0] used for update)
    input  logic [7:0] uio_in,     // Input data for the first neuron
    output logic [7:0] uo_out,     // Output from the last neuron
    input  logic clk,             // Clock signal
    input  logic rst_n            // Active-low reset
);
    // Internal wires to hold each neuron's output
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the first neuron in the array
    single_neuron_dut neuron0 (
        .clk(clk),
        .rst_n(rst_n),
        .control(ui_in[0]),
        .seq_in(uio_in),
        .seq_out(neuron_outputs[0])
    );

    // Instantiate remaining neurons, chaining the outputs sequentially
    genvar i;
    generate
       for (i = 1; i < NEURONS; i = i + 1) begin : neuron_chain
          single_neuron_dut neuron (
              .clk(clk),
              .rst_n(rst_n),
              .control(ui_in[0]),
              .seq_in(neuron_outputs[i-1]),
              .seq_out(neuron_outputs[i])
          );
       end
    endgenerate

    // The final output is taken from the last neuron's output
    assign uo_out = neuron_outputs[NEURONS-1];

endmodule

module single_neuron_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic control,        // Control signal: 1 enables update
    input  logic [7:0] seq_in,   // Input data for the neuron
    output logic [7:0] seq_out   // Output of the neuron (stored state)
);
    // Internal register to hold the neuron's state
    logic [7:0] state;

    // Sequential logic: on reset, clear state; on update, load seq_in; otherwise retain state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= 8'b0;
        else if (control)
            state <= seq_in;
        else
            state <= state;
    end

    // Drive the output with the current state
    assign seq_out = state;

endmodule