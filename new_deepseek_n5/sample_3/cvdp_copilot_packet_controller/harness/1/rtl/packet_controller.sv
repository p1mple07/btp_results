module packet_controller(
    input clock,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i,
    input tx_done_tick_i,
    output tx_start_o,
    output [7:0] tx_data_8_o
);

    // State variables
    enum state_t state = S_IDLE;
    enum state_t current_opcode = 0;

    // FIFO buffer for accumulating received data
    FIFO FIFO(8)fifo;

    // State transition table
    always @posedge clock begin
        case (state)
            S_IDLE:
                if (rst) state = S_IDLE; // Active-high reset
                else if (rx_valid_i) begin
                    fifo.push(rx_data_8_i);
                    if (fifo.size() == 8) state = S_GOT_8_BYTES;
                end
            S_GOT_8_BYTES:
                if (fifo.size() == 8) begin
                    byte_t [7:0] received = fifo.pop();
                    if (received[16:0] != 0x1234) state = S_IDLE; // Invalid header
                    else begin
                        byte_t sum = 0;
                        for (int i = 0; i < 8; i++) sum += fifo.pop()[7:0];
                        if (sum % 256 != 0) state = S_IDLE; // Invalid checksum
                        else state = S_RECV_CHECKSUM;
                    end
                end
            S_RECV_CHECKSUM:
                if (rx_valid_i) begin
                    byte_t [7:0] received = rx_data_8_i;
                    if (received != 0x1234) state = S_IDLE; // Invalid checksum
                    else state = S_BUILD_RESPONSE;
                end
            S_BUILD_RESPONSE:
                byte_t [7:0] payload;
                case (current_opcode)
                    0x00: payload = rx_data_8_i;
                    0x01: payload = rx_data_8_i;
                    default: payload = 0;
                endcase
                fifo.write(0x1234);
                fifo.write(payload);
                state = S_SEND_FIRST_BYTE;
            S_SEND_FIRST_BYTE:
                if (tx_done_tick_i) begin
                    fifo.write(payload);
                    if (fifo.size() == 5) state = S_RESPONSE_READY;
                end
            S_RESPONSE_READY:
                if (tx_done_tick_i) state = S_IDLE;
        endcase
    end

    // Output the accumulated data when done
    always @posedge clock begin
        if (state == S_RESPONSE_READY) begin
            tx_start_o = 1;
            tx_data_8_o = fifo.pop();
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
            fifo.write(fifo.pop());
        end
    end

    // Initial state setup
    initial begin
        state = S_IDLE;
        current_opcode = 0;
    end

endmodule