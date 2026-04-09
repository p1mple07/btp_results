module packet_controller(
    input clock,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i,
    input tx_done_tick_i,
    output [7:0] tx_data_8_o,
    output tx_start_o
);

    // State variables
    enum states S_IDLE, S_GOT_8_BYTES, S_RECV_CHECKSUM, S_BUILD_RESPONSE, S_SEND_FIRST_BYTE, S_RESPONSE_READY;
    reg state = S_IDLE;

    // FIFO buffer for received data
    reg [8][8] rx_buffer;

    // State transition logic
    always clock'posed when clockposed) begin
        case (state)
            S_IDLE:
                if (rst) state = S_IDLE;
                else if (rx_valid_i) begin
                    rx_buffer[0] = rx_data_8_i;
                    state = S_GOT_8_BYTES;
                end
            S_GOT_8_BYTES:
                if (rx_valid_i) begin
                    rx_buffer[1:7] = rx_buffer[0:6];
                    rx_buffer[7] = rx_data_8_i;
                    state = S_RECV_CHECKSUM;
                end
            S_RECV_CHECKSUM:
                if (rx_valid_i) begin
                    rx_buffer[1:8] = rx_buffer[0:7];
                    rx_buffer[8] = rx_data_8_i;
                    state = S_BUILD_RESPONSE;
                end
            S_BUILD_RESPONSE:
                if (rx_valid_i) begin
                    // Compute response packet
                    byte1 = rx_data_8_i;
                    byte2 = rx_data_8_i;
                    byte3 = (opcode == 8'h00) ? (byte1 + byte2) : ((opcode == 8'h01) ? (byte1 - byte2) : 0);
                    byte4 = 0;
                    byte5 = 0;
                    // Set checksum
                    byte6 = (byte1 + byte2 + byte3 + byte4 + byte5) % 256;
                    // Prepare response
                    tx_data_8_o[4:0] = {byte1, byte2, byte3, byte4, byte5};
                    tx_start_o = 1;
                    state = S_SEND_FIRST_BYTE;
                end
            S_SEND_FIRST_BYTE:
                if (rx_valid_i) begin
                    tx_data_8_o[4:0] = {byte1, byte2, byte3, byte4, byte5};
                    state = S_RESPONSE_READY;
                end
            S_RESPONSE_READY:
                if (rx_valid_i) begin
                    tx_data_8_o[4:0] = {byte1, byte2, byte3, byte4, byte5};
                    state = S_IDLE;
                end
        endcase
    end

    // Header validation
    local [2] header = rx_buffer[0:1];
    if (header != 0x1213) state = S_IDLE;

    // Checksum validation
    local [8] sum = rx_buffer[0:7];
    if ((sum % 256) != 0) state = S_IDLE;

    // Opcode handling
    local [2] opcode = rx_buffer[2:3];
    byte3 = (opcode == 8'h00) ? (byte1 + byte2) : ((opcode == 8'h01) ? (byte1 - byte2) : 0);

    // Initial state
    initial state = S_IDLE;

endmodule