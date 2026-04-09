
module single_neuron_dut (
    input logic clk,
    input logic rst_n,
    input logic control,        // Control signal
    input logic [7:0] seq_in,   // Input sequence
    output logic [7:0] seq_out   // Output sequence
);
    logic [7:0] state;
    logic last_update;

    // Reset logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            state <= 8'd0;
            last_update <= 1'b0;
        end else if (control) begin
            state <= seq_in;
            last_update <= 1'b1;
        end
    end

    // Sequential logic
    always @(posedge clk) begin
        if (last_update) begin
            seq_out <= state;
            last_update <= 1'b0;
        end
    end

endmodule

module neuromorphic_array #(
    parameter NEURONS = 8,       // Number of neurons
    parameter INPUTS = 8,        // Number of inputs
    parameter OUTPUTS = 8         // Number of outputs
) (
    input  logic [7:0] ui_in,       // Control input
    input logic [7:0] uio_in,      // Input data
    output logic [7:0] uo_out,     // Output data
    input logic clk,                // Clock
    input logic rst_n               // Reset
);
    // Internal wires for neuron outputs
    logic [7:0] neuron_outputs [0:NEURONS-1];

    // Instantiate the neurons
    genvar i;
    generate
        for (i = 0; i < NEURONS; i = i + 1) begin
            single_neuron_dut u_neuron_dut_inst(
                .clk(clk),
                .rst_n(rst_n),
                .control(ui_in[0]),
                .seq_in(uio_in),
                .seq_out(neuron_outputs[i])
            );
        end
    endgenerate

    // Combine outputs from the last neuron
    assign uo_out = neuron_outputs[NEURONS-1]; // Output from the last neuron

endmodule

