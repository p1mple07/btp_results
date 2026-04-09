module packet_controller(
    input clock,
    input rst,
    input [7:0] rx_valid_i,
    input [7:0] rx_data_8_i,
    input [7:0] tx_done_tick_i,
    output [7:0] tx_data_8_o,
    output tx_start_o
);

    // State register
    reg [_fsm_state] fsm_state = S_IDLE;

    // Buffers and registers
    reg [7:0] buffer [8];
    reg [7:0] checksum;
    reg [7:0] response [5];
    reg [16:0] num1, num2;
    reg [16:0] result;
    reg [16:0] new_checksum;

    // State transitions
    always @(posedge clock) begin
        case (fsm_state)
            S_IDLE:
                if (rst) begin
                    fsm_state = S_IDLE;
                    buffer = 8'b00000000;
                    checksum = 8'h0000;
                    num1 = 8'h0000;
                    num2 = 8'h0000;
                    result = 8'h0000;
                    new_checksum = 8'h0000;
                end else if (rx_valid_i) begin
                    buffer[7] = rx_data_8_i;
                    buffer[6:0] = buffer[7:1];
                    buffer[5:0] = buffer[6:2];
                    buffer[4:0] = buffer[7:3];
                    buffer[3:0] = buffer[6:4];
                    buffer[2:0] = buffer[7:4];
                    buffer[1:0] = buffer[6:5];
                    buffer[0] = buffer[7:5];
                    fsm_state = S_GOT_8_BYTES;
                end
            S_GOT_8_BYTES:
                if (rx_valid_i) begin
                    checksum = 0;
                    for (int i = 0; i < 8; i++) begin
                        checksum = (checksum + buffer[i]) % 256;
                    end
                    if (buffer[0] != 0x16 || buffer[1] != 0xAC || buffer[2] != 0xBD || buffer[3] != 0xCD) begin
                        fsm_state = S_IDLE;
                        continue;
                    end
                    if (checksum != 0) begin
                        fsm_state = S_IDLE;
                        continue;
                    end
                    fsm_state = S_RECV_CHECKSUM;
                end
            S_RECV_CHECKSUM:
                if (rx_valid_i) begin
                    new_checksum = 0;
                    for (int i = 0; i < 8; i++) begin
                        new_checksum = (new_checksum + buffer[i]) % 256;
                    end
                    if (new_checksum != 0) begin
                        fsm_state = S_IDLE;
                        continue;
                    end
                    fsm_state = S_BUILD_RESPONSE;
                end
            S_BUILD_RESPONSE:
                if (rx_valid_i) begin
                    case (opcode)
                        0x00: result = num1 + num2;
                        0x01: result = num1 - num2;
                        default: result = 0;
                    endcase
                    new_checksum = 0;
                    for (int i = 0; i < 5; i++) begin
                        new_checksum = (new_checksum + response[i]) % 256;
                    end
                    if (new_checksum != 0) begin
                        fsm_state = S_IDLE;
                        continue;
                    end
                    fsm_state = S_SEND_FIRST_BYTE;
                end
            S_SEND_FIRST_BYTE:
                if (rx_valid_i) begin
                    tx_start_o = 1;
                    tx_data_8_o[4] = result;
                    fsm_state = S_RESPONSE_READY;
                end
            S_RESPONSE_READY:
                if (rx_valid_i) begin
                    tx_data_8_o[3] = response[0];
                    tx_data_8_o[2] = response[1];
                    tx_data_8_o[1] = response[2];
                    tx_data_8_o[0] = response[3];
                    fsm_state = S_IDLE;
                end
        end
    end

    // Initial state setup
    initial begin
        fsm_state = S_IDLE;
        buffer = 8'b00000000;
        checksum = 8'h0000;
        num1 = 8'h0000;
        num2 = 8'h0000;
        result = 8'h0000;
        new_checksum = 8'h0000;
    end
endmodule