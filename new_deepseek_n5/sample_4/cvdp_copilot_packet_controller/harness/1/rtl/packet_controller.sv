module packet_controller(
    input clock,
    input rst,
    input rx_valid_i,
    input[7:0] rx_data_8_i,
    input tx_done_tick_i,
    output tx_start_o,
    output[7:0] tx_data_8_o
);

    // State variables
    reg [15:0] state = 0; // 0: S_IDLE, 1: S_GOT_8_BYTES, 2: S_RECV_CHECKSUM, 3: S_BUILD_RESPONSE, 4: S_SEND_FIRST_BYTE, 5: S_RESPONSE_READY
    reg [7:0] buffer = 0;
    reg [7:0] ptr = 0;

    // FSM transitions
    always clocked begin
        case (state)
            S_IDLE: 
                if (rst) state = S_IDLE;
                else if (rx_valid_i) begin
                    buffer = rx_data_8_i;
                    ptr = ptr + 1;
                    if (ptr == 8) state = S_GOT_8_BYTES;
                end
            S_GOT_8_BYTES: 
                if (rx_valid_i) begin
                    if (buffer[0:1] != 0x16BACD) state = S_IDLE;
                    else begin
                        // Compute checksum
                        integer sum = 0;
                        for (int i = 0; i < 8; i++) sum += buffer[3:7][i] & 127;
                        sum = sum % 256;
                        if (sum != buffer[7:0]) state = S_IDLE;
                        else state = S_RECV_CHECKSUM;
                    end
                end
            S_RECV_CHECKSUM: 
                if (rx_valid_i) begin
                    if (ptr == 7) state = S_BUILD_RESPONSE;
                    else state = S_RECV_CHECKSUM;
                end
            S_BUILD_RESPONSE: 
                if (rx_valid_i) state = S_SEND_FIRST_BYTE;
            S_SEND_FIRST_BYTE: 
                if (rx_valid_i) state = S_RESPONSE_READY;
            S_RESPONSE_READY: 
                if (rx_valid_i) state = S_IDLE;
        endcase
    end

    // Response generation
    always clocked begin
        case (state)
            S.Build_Response: 
                tx_start_o = 1;
                tx_data_8_o = {0x16ABCD, (num1 + num2) & 0xFF, 0x00, 0x00, 0x00};
            S.Send_First_byte: 
                tx_start_o = 1;
                tx_data_8_o = buffer[0:7];
            S.Response_READY: 
                tx_start_o = 0;
                tx_data_8_o = 0;
        endcase
    end

    // Initial state setup
    initial begin
        state = S_IDLE;
        ptr = 0;
    end
endmodule