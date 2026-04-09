module packet_controller(
    input clock,
    input rst,
    input rx_valid_i,
    input rx_data_8_i,
    input tx_done_tick_i,
    output tx_start_o,
    output tx_data_8_o
);

    // State variables
    enum state S = 0;
    reg S_next;

    // Buffers
    reg [7:0] rx_buffer;
    reg [7:0] rx_buffer_count;

    // FSM states
    always @posedge clock begin
        case (S)
            S_IDLE: 
                if (rst) S_next = S_IDLE;
                else if (rx_valid_i) begin
                    rx_buffer_count = 0;
                    rx_buffer = 0;
                end
                else S_next = S_IDLE;

            S_GOT_8_BYTES: 
                if (rx_buffer_count == 8) begin
                    // Validate header and checksum
                    byte [7:0] header = rx_buffer[7:0];
                    byte [7:0] checksum = 0;
                    for (int i = 0; i < 8; i++) {
                        byte [7:0] data = rx_buffer[7:0];
                        checksum = (checksum + data) % 256;
                    }
                    if (checksum == 0) S_next = S_RECV_CHECKSUM;
                    else S_next = S_IDLE;
                end
                else S_next = S_IDLE;

            S_RECV_CHECKSUM: 
                if (checksum == 0) S_next = S_BUILD_RESPONSE;
                else S_next = S_IDLE;

            S_BUILD_RESPONSE: 
                // Build response packet
                rx_buffer = 0x1234;
                rx_buffer_count = 8;
                S_next = SSEND_FIRST_BYTE;

            SSEND_FIRST_BYTE: 
                rx_buffer[7:0] = rx_buffer[7:0] << 1;
                rx_buffer_count = rx_buffer_count - 1;
                S_next = S_RESPONSE_READY;

            S_RESPONSE_READY: 
                for (int i = 0; i < 4; i++) {
                    rx_buffer[7:0] = rx_buffer[7:0] << 1;
                    rx_buffer_count = rx_buffer_count - 1;
                    // Send data on tx_done_tick_i
                    if (i == 4) {
                        tx_start_o = 1;
                        tx_data_8_o = rx_buffer[7:0];
                    }
                    // else: tx_data_8_o remains 0
                }
                S_next = S_IDLE;
        endcase
    end

    // Initial state
    always @posedge clock begin
        if (rst) S = S_IDLE;
    end

    // Output tx_start_o and tx_data_8_o
    tx_start_o = 0;
    tx_data_8_o = 0;

    // Checksum calculation
    function integer checksum(byte [7:0] data) {
        integer sum = 0;
        for (int i = 0; i < 8; i++) {
            sum = (sum + data[i]) % 256;
        }
        return sum;
    }
endmodule