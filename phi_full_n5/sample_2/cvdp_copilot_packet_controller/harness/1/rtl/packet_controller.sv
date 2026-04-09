module packet_controller(
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i,
    input tx_done_tick_i,
    output reg tx_start_o,
    output reg [7:0] tx_data_8_o
);

    // State declaration
    typedef enum {
        S_IDLE,
        S_GOT_8_BYTES,
        S_RECV_CHECKSUM,
        S_BUILD_RESPONSE,
        S_SEND_FIRST_BYTE,
        S_RESPONSE_READY
    } state_t;

    reg [2:0] current_state;
    reg [7:0] header_received;
    reg [15:0] num1, num2;
    reg [7:0] opcode, checksum;
    reg [7:0] response_payload;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_IDLE;
        else begin
            case (current_state)
                S_IDLE: if (rx_valid_i) begin
                                header_received <= rx_data_8_i;
                                current_state <= S_GOT_8_BYTES;
                            end
                S_GOT_8_BYTES: begin
                                if (header_received == 16'hBACD) begin
                                    num1 <= rx_data_8_i[7:0];
                                    num2 <= rx_data_8_i[15:8];
                                    opcode <= rx_data_8_i[7:0];
                                    checksum <= rx_data_8_i[15:8];
                                    current_state <= S_RECV_CHECKSUM;
                                end
                                else current_state <= S_IDLE;
                            end
                S_RECV_CHECKSUM: begin
                                if ((checksum == rx_data_8_i[15:8]) || (checksum == 0)) begin
                                    current_state <= S_BUILD_RESPONSE;
                                end else current_state <= S_IDLE;
                            end
                S_BUILD_RESPONSE: begin
                                if (opcode == 8'h00) begin
                                    response_payload <= num1 + num2;
                                    current_state <= S_SEND_FIRST_BYTE;
                                end else if (opcode == 8'h01) begin
                                    response_payload <= num1 - num2;
                                    current_state <= S_SEND_FIRST_BYTE;
                                end else begin
                                    current_state <= S_IDLE;
                                end
                            end
                S_SEND_FIRST_BYTE: begin
                                tx_start_o <= 1'b1;
                                tx_data_8_o <= {response_payload, 8'hABCD};
                                current_state <= S_RESPONSE_READY;
                            end
                S_RESPONSE_READY: begin
                                tx_start_o <= 1'b0;
                                if (tx_done_tick_i) begin
                                    // Transmit next byte of response
                                    // Assume a separate module handles transmission
                                    current_state <= S_RESPONSE_READY;
                                end else current_state <= S_IDLE;
                            end
                        end
            endcase
        end
    end

    // Additional logic for handling other edge cases, timing constraints, and error handling
    // would be implemented here, including FSM reset logic, checksum validation, and
    // arithmetic operations with overflow/underflow handling as required.

endmodule
