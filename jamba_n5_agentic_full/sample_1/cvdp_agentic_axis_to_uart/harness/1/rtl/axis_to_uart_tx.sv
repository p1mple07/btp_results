module axis_to_uart_tx #(
    parameter CLK_FREQ = 100,
    parameter BIT_RATE = 115200,
    parameter BIT_PER_WORD = 8,
    parameter PARITY_BIT = 0,
    parameter STOP_BITS_NUM = 1
)(
    input aclk,
    input aresetn,
    input tdata,
    input tvalid,
    input tready,
    output reg [7:0] TX
);

reg [7:0] clk_cnt;
reg [2:0] state;
reg [2:0] next_state;

// State machine transitions
always @(posedge aclk or posedge aresetn) begin
    if (aresetn)
        state <= IDLE;
    else
        case (state)
            IDLE: begin
                if (tvalid && tready) begin
                    next_state = START;
                end else
                    next_state = IDLE;
            end
            START: begin
                tdata = 1'b0;
                next_state = DATA;
            end
            DATA: begin
                // Transmit data bits (LSB first)
                TX = {tdata[BIT_PER_WORD-1:0]};
                next_state = PARITY;
            end
            PARITY: begin
                // Compute parity (simplified)
                TX = TX;
                next_state = STOP1;
            end
            STOP1: begin
                TX = 1'b0;
                next_state = STOP2;
            end
            STOP2: begin
                TX = 1'b1;
                next_state = IDLE;
            end
        endcase
end

always @(*) begin
    clk_cnt = 0;
    if (aclk)
        if (!tready)
            clk_cnt <= clk_cnt + 1;
    else
        clk_cnt <= clk_cnt + 1;
end

always @(posedge aclk) begin
    if (clk_cnt >= (CYCLE_PER_PERIOD)) begin
        clk_cnt <= 0;
        state = START;
    end
end

endmodule
