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

    generate
        #i
        logic [7:0] seq_in,
        logic [7:0] seq_out
        single_neuron_dut (
            clk,
            rst_n,
            ui_in[0],
            uio_in if i == 0 else neuron_outputs[i-1],
            neuron_outputs[i]
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
    always @ (posedge clk) begin
        if (rst_n) 
            # Clear the state
            seq_out = 0;
        else
            # Update the state if control is active
            seq_out = seq_in & control | ~control & #1 seq_out;
        end
    end
endmodule