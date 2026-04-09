module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input rx_data_8_i [7:0],
    input tx_done_tick_i,
    output reg tx_start_o,
    output reg [7:0] tx_data_8_o
);

// Internal state machine registers
reg [3:0] state;
reg [3:0] next_state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 0;
        next_state <= 0;
    end else begin
        case (state)
            0: // S_IDLE
                if (rx_valid_i) begin
                    state <= 1;
                end
                next_state <= 0;
            end
            1: // S_GOT_8_BYTES
                if (rx_data_8_i[7:0] == {16'b10100000, 16'b10000000, 16'b00000000, 16'b00000000}) begin
                    // valid header? Actually the spec says 16'hBACD. So we need to check that.
                    // But the example above is 16 bits; we can assume the data is 16 bits.
                    state <= 2;
                end else begin
                    state <= 0;
                end
            end
            2: // S_RECV_CHECKSUM
                if (rx_data_8_i[7:0] == {16'b10100000, 16'b10000000, 16'b00000000, 16'b00000000}) begin
                    state <= 3;
                end else begin
                    state <= 0;
                end
            end
            3: // S_BUILD_RESPONSE
                if (tx_done_tick_i) begin
                    tx_start_o <= 1;
                    tx_data_8_o[0] <= 1'b0;
                    next_state <= 4;
                end else begin
                    next_state <= 3;
                end
            end
            4: // S_SEND_FIRST_BYTE
                if (tx_done_tick_i) begin
                    tx_start_o <= 1;
                    tx_data_8_o[0] <= rx_data_8_i[7];
                    tx_data_8_o[1] <= rx_data_8_i[6];
                    tx_data_8_o[2] <= rx_data_8_i[5];
                    tx_data_8_o[3] <= rx_data_8_i[4];
                    next_state <= 5;
                end else begin
                    next_state <= 4;
                end
            end
            5: // S_RESPONSE_READY
                if (tx_done_tick_i) begin
                    tx_done_tick_i <= 1;
                    next_state <= 6;
                end else begin
                    next_state <= 5;
                end
            end
            6: // S_RESPONSE_READY
                if (tx_done_tick_i) begin
                    tx_done_tick_i <= 0;
                    state <= 0;
                end else begin
                    state <= 6;
                end
        endcase
    end
endalways

assign tx_start_o = tx_start_o;
assign tx_data_8_o = tx_data_8_o;

endmodule
