module packet_controller(
    input wire clk,
    input wire rst,
    input wire rx_valid_i,
    input wire [7:0] rx_data_8_i,
    input wire tx_done_tick_i,
    output reg tx_start_o,
    output reg [7:0] tx_data_8_o
);

    // FSM states
    enum logic[2:0] {
        S_IDLE,
        S_GOT_8_BYTES,
        S_RECV_CHECKSUM,
        S_BUILD_RESPONSE,
        S_SEND_FIRST_BYTE,
        S_RESPONSE_READY,
        S_ERROR
    } state, next_state;

    // FSM state register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM state transition logic
    always @* begin
        case (state)
            S_IDLE: begin
                // Wait for 8 bytes of data to accumulate in the buffer
                if (rx_valid_i) begin
                    next_state = S_GOT_8_BYTES;
                end else begin
                    next_state = S_IDLE;
                end
            end

            S_GOT_8_BYTES: begin
                // Check the header and compute the checksum
                if (rx_data_8_i == 16'dBACD) begin
                    next_state = S_RECV_CHECKSUM;
                end else begin
                    next_state = S_ERROR;
                end
            end

            S_RECV_CHECKSUM: begin
                // Validate the checksum
                // Compute the checksum
                // Prepare the outgoing response packet
                next_state = S_BUILD_RESPONSE;
            end

            S_BUILD_RESPONSE: begin
                // Send the first byte of the response
                next_state = S_SEND_FIRST_BYTE;
            end

            S_SEND_FIRST_BYTE: begin
                // Handle the remaining response transmission
                next_state = S_RESPONSE_READY;
            end

            S_RESPONSE_READY: begin
                // Handle the response transmission
                next_state = S_IDLE;
            end

            S_ERROR: begin
                // Reset to IDLE on invalid checksum or unexpected header
                next_state = S_IDLE;
            end
        endcase
    end

    // FSM output assignment
    always @* begin
        case (state)
            S_IDLE: begin
                tx_start_o = 1'b0;
                tx_data_8_o = 8'b0;
            end

            S_GOT_8_BYTES: begin
                tx_start_o = 1'b1;
                tx_data_8_o = rx_data_8_i;
            end

            S_RECV_CHECKSUM: begin
                // Calculate the checksum
                // Send the computed checksum
                // Prepare the outgoing response packet
                next_state = S_BUILD_RESPONSE;
            end

            S_BUILD_RESPONSE: begin
                // Compute the response based on the opcode
                // Send the computed response
                next_state = S_SEND_FIRST_BYTE;
            end

            S_SEND_FIRST_BYTE: begin
                // Send the first byte of the response
                next_state = S_RESPONSE_READY;
            end

            S_RESPONSE_READY: begin
                // Send the remaining bytes of the response
                next_state = S_IDLE;
            end

            S_ERROR: begin
                // Reset to IDLE on invalid checksum or unexpected header
                next_state = S_IDLE;
            end
        endcase
    end

endmodule