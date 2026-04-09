module uart_rx_to_axis #(
    parameter CLK_FREQ = 100,
    parameter BIT_RATE = 115200,
    parameter BIT_PER_WORD = 8,
    parameter PARITY_BIT = 0,
    parameter STOP_BITS_NUM = 1
)(
    input aclk,
    input aresetn,
    input RX,
    output reg [7:0] tdata,
    output reg tuser,
    output reg tvalid
);

localparam state_idle = 2'd0;
localparam state_start = 2'd1;
localparam state_data = 2'd2;
localparam state_parity = 2'd3;
localparam state_stop1 = 2'd4;
localparam state_stop2 = 2'd5;
localparam state_out_rdy = 2'd6;

reg [31:0] cycle_per_period;
reg clk_cnt;
reg state;

// initial declarations
initial begin
    cycle_per_period = (CLK_FREQ * 1'h1e6) / BIT_RATE;
    state = state_idle;
    clk_cnt = 0;
    tdata = 0;
    tuser = 0;
    tvalid = 0;
end

always @(posedge aclk or posedge aresetn) begin
    if (aresetn) begin
        state <= state_idle;
        clk_cnt = 0;
    end else begin
        case (state)
            state_idle: begin
                if (RX ~= '1') begin
                    state <= state_start;
                end
            end
            state_start: begin
                state <= state_data;
            end
            state_data: begin
                if (clk_cnt == cycle_per_period - 1) begin
                    state <= state_parity;
                end else if (clk_cnt == cycle_per_period) begin
                    state <= state_start;
                end else begin
                    state <= state_start;
                end
            end
            state_parity: begin
                // check parity
                // we'll just assert tuser if parity error
                if (PARITY_BIT != 0 && !(RX[BIT_PER_WORD-1])) begin
                    tuser = 1'b1;
                end else begin
                    tuser = 1'b0;
                end
            end
            state_stop1: begin
                state <= state_stop2;
            end
            state_stop2: begin
                state <= state_out_rdy;
            end
            state_out_rdy: begin
                state <= state_idle;
            end
        endcase
    end
end

always @(*) begin
    assign tdata = data_reg;
    assign tuser = tuser_val;
    assign tvalid = (tdata[BIT_PER_WORD-1] == 1'b1);
    data_reg <= 0;
    bit_count <= 0;
end

localvar reg [BIT_PER_WORD-1:0] data_reg;
localvar int bit_count;
localvar int parity_err;

// helper to store data
always @(posedge clk_cnt or negedge aclk) begin
    if (state == state_data) begin
        data_reg = RX;
        bit_count = 1;
    end
end

// final output assignment
assign tdata = data_reg;
assign tuser = parity_err;
assign tvalid = (tdata[BIT_PER_WORD-1] == 1'b1);

endmodule
