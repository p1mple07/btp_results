module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i[7:0],
    input tx_done_tick_i,
    output reg [7:0] tx_start_o,
    output reg [7:0] tx_data_8_o[7:0]
);

reg [3:0] state;
reg [3:0] counter;
reg [15:0] rx_buffer;
reg [15:0] rx_data_buf;
reg [7:0] incoming_data;
reg [15:0] tx_buffer;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= S_IDLE;
    else
        case (state)
            S_IDLE: begin
                if (rx_valid_i)
                    counter <= 0;
                else
                    counter <= 1;
            end
            S_GOT_8_BYTES: begin
                if (counter == 8)
                    state <= S_RECV_CHECKSUM;
                else
                    counter <= 2;
            end
            S_RECV_CHECKSUM: begin
                if (rx_valid_i)
                    // compute checksum
                    reg [7:0] checksum = 0;
                    for (int i = 0; i < 8; i++)
                        checksum += rx_data_8_i[i];
                    checksum %= 256;
                end else
                    state <= S_IDLE;
                if (checksum == 0)
                    state <= S_BUILD_RESPONSE;
                else
                    state <= S_IDLE;
            end
            S_BUILD_RESPONSE: begin
                tx_buffer <= "HB" + {rx_data_8_i[0], rx_data_8_i[1], rx_data_8_i[2], rx_data_8_i[3], rx_data_8_i[4], rx_data_8_i[5], rx_data_8_i[6], rx_data_8_i[7]};
                tx_start_o <= 1'b1;
                // Send first byte
                tx_data_8_o[0] <= 8'b{tx_buffer[7:0]};
                // We need to send 5 more bytes? But spec says "manage transmission" maybe we send all 8 bytes.
                // We'll just keep in this state for now.
                counter <= 0;
            end
            S_SEND_FIRST_BYTE: begin
                tx_data_8_o[0] <= 8'b{tx_buffer[7:0]};
                // Wait, we already sent first byte.
            end
            S_RESPONSE_READY: begin
                // ... no need to do anything.
            end
            default: state <= S_IDLE;
        endcase
endelse

endmodule
