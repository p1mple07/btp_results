module cic_decimator #(
    parameter WIDTH=16,
    parameter RMAX=2,
    parameter M=1,
    parameter N=2,
    parameter REG_WIDTH=W + $clog2((RMAX*M)**N)
)(
    input wire clk,
    input wire rst,
    input wire input_tvalid,
    input wire input_tready,
    input wire output_tdata,
    output reg output_tvalid,
    output reg output_tready
);

    // Internal registers
    reg [WIDTH-1:0] accum_int[N];
    reg [WIDTH-1:0] accum_comb[N];
    reg [WIDTH-1:0] delay_reg[WIDTH-1];
    reg [N-1:0] cycle_reg;

    // Counters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            accum_int[0:N-1] <= 0;
            accum_comb[0:N-1] <= 0;
            delay_reg[0:N-1] <= 0;
            cycle_reg <= 0;
            output_tdata <= 0;
            output_tvalid <= 0;
            output_tready <= 0;
        end else begin
            // Integrator accumulation
            for (int i = 0; i < N; i++) begin
                if (input_tready && input_tvalid) begin
                    accum_int[i] <= accum_int[i] + input_tdata;
                end
            end

            // Comb differentiator
            for (int i = 0; i < N; i++) begin
                if (output_tvalid) begin
                    accum_comb[i] <= accum_comb[i] - delay_reg[i];
                end
            end

            // Decimation
            if (input_tvalid && ~input_tready) begin
                input_tready <= 1;
                output_tready <= 1;
            end else if (input_tvalid && input_tready && cycle_reg == 0) begin
                output_tvalid <= 1;
                output_tready <= 1;
            end

            // Counter
            if (cycle_reg == RMAX - 1) begin
                cycle_reg <= 0;
            end else begin
                cycle_reg <= cycle_reg + 1;
            end
        end
    end

endmodule
