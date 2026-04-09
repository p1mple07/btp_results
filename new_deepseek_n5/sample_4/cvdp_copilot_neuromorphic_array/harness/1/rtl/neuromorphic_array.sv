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
        localparam control = ui_in[0];
        single_neuron_dut
            #(
                clk = clk,
                rst_n = rst_n,
                control = control,
                seq_in = uio_in,
                seq_out = neuron_outputs[i]
            )
            instantiate(i);
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
    always @posedge clk begin
        if (rst_n) 
            seq_out = 0;
        else
            seq_out = seq_in;
        end
    end
endmodule