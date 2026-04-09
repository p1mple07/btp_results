module cic_decimator #(
    parameter WIDTH = 16,
    parameter RMAX = 2,
    parameter M = 1,
    parameter N = 2
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] input_tdata,
    input wire input_tvalid,
    input wire input_tready,
    output reg [WIDTH-1:0] output_tdata,
    output reg output_tvalid,
    output wire output_tready
);

// Integrator stages
logic reg [WIDTH-1:0] acc_integrator[N];

// Comb stages
logic reg [WIDTH-1:0] delay_reg[N];

// Internal signals
integer i, j;

// Integrator generation
always @(posedge clk or posedge reset) begin
    if (!rst) begin
        for (i = 0; i < N; i++) begin
            acc_integrator[i] <= 0;
        end
    end else begin
        for (i = 0; i < N; i++) begin
            acc_integrator[i] <= acc_integrator[i] + input_tdata;
        end
    end
end

// Comb generation
always @(posedge clk or posedge reset) begin
    if (!rst) begin
        for (i = 0; i < N; i++) begin
            delay_reg[i] <= 0;
        end
    end else begin
        for (i = 0; i < N; i++) begin
            delay_reg[i] <= delay_reg[i-1];
        end
    end
end

// Output generation
always @(posedge clk or posedge reset) begin
    if (!rst) begin
        output_tdata <= 0;
        output_tvalid <= 0;
        output_tready <= 1;
    end else begin
        output_tdata <= acc_integrator[N-1];
        output_tvalid <= 1;
        output_tready <= output_tvalid;
    end
end

endmodule
