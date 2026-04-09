module cic_decimator #(
    parameter WIDTH = 16,
    parameter RMAX = 2,
    parameter M = 1,
    parameter N = 2
) (
    input clk,
    input rst_n,
    input [WIDTH-1:0] input_tdata,
    input tvalid_in,
    input tready_in,
    output reg [WIDTH-1:0] output_tdata,
    output reg tvalid_out,
    output reg tready_out
);

    localparam int LOG2_RW = $clog2(WIDTH);
    localparam int REG_WIDTH = WIDTH + (RMAX * M);

    // Integrator stages
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            accumulators <= {WIDTH{1'b0}};
            output_tdata <= {WIDTH{1'b0}};
            tvalid_out <= 1'b0;
            tready_out <= 1'b1;
        end else begin
            for (int i = 0; i < N; i++) begin
                accumulators[i] = input_tdata[i];
            end
        end
    end

    // Comb stages
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            output_tdata <= {WIDTH{1'b0}};
            tvalid_out <= 1'b0;
            tready_out <= 1'b1;
        end else begin
            for (int k = 0; k < N; k++) begin
                if (k == 0) begin
                    delay_reg[0] <= accumulators[0];
                end else begin
                    for (int j = 1; j < N; j++) begin
                        delay_reg[j] <= delay_reg[j-1];
                    end
                end
            end
        end
    end

    // Decimation control
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            cycle_reg <= 0;
        end else begin
            cycle_reg <= cycle_reg + 1;
        end
    end

    // Output validity and handshake
    assign output_tvalid = (input_tvalid && cycle_reg == 0);
    assign tready_out = output_tready;

    // Output data
    assign output_tdata = accumulators[N-1];

endmodule
