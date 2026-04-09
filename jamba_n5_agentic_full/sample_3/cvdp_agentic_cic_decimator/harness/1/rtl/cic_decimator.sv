module cic_decimator #(
    parameter WIDTH = 16,
    parameter RMAX = 2,
    parameter M = 1,
    parameter N = 2,
    parameter REG_WIDTH = WIDTH + $clog2((RMAX * M) ** N)
)(
    input clk,
    input rst,
    input [WIDTH-1:0] input_tdata,
    input          input_tvalid,
    input          input_tready,
    output reg [WIDTH-1:0] output_tdata,
    output reg       output_tvalid,
    output reg       output_tready
);

    // Internal registers
    reg [WIDTH-1:0] accum;
    reg [WIDTH-1:0] delay;
    reg [WIDTH-1:0] prev_accum;
    reg [WIDTH-1:0] comb_out;
    reg cycle_reg;
    reg output_tvalid_logic;
    reg [WIDTH-1:0] output_tready_logic;
    reg [WIDTH-1:0] output_tdata_logic;

    // Counters
    integer cycle_counter;
    initial begin
        cycle_counter = 0;
        @(posedge clk);
        while (!done) begin
            if (input_tvalid && input_tready) begin
                cycle_counter = cycle_counter + 1;
            end
            else begin
                cycle_counter = 0;
            end
        end
    end

    // Integrator generation
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : integrator_loop
            always_comb begin
                if (input_tvalid && input_tready) begin
                    accum = input_tdata + accum;
                end
            end
        end
    endgenerate

    // Comb section
    genvar j;
    generate
        for (j = 0; j < N; j++) begin : comb_loop
            always_comb begin
                if (output_tready && output_tvalid) begin
                    comb_out = delay[0];
                end
            end
        end
    endgenerate

    // Assign output values
    assign output_tdata = comb_out;
    assign output_tready_logic = (cycle_reg == min(RMAX - 1, RMAX * M)) ? 1 : 0;
    assign output_tvalid = input_tvalid && output_tready;

    // Output signals
    assign output_tvalid_logic = output_tvalid;
    assign output_tready_logic = output_tready;

    assign output_tdata_logic = output_tdata;

endmodule
