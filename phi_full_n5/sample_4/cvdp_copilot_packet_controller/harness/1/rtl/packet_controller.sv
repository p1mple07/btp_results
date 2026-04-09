module packet_controller(
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i,
    output tx_start_o,
    output reg [7:0] tx_data_8_o
);

    // State encoding
    typedef enum logic [2:0] {
        S_IDLE,
        S_GOT_8_BYTES,
        S_RECV_CHECKSUM,
        S_BUILD_RESPONSE,
        S_SEND_FIRST_BYTE,
        S_RESPONSE_READY
    } state_t;

    // State register
    reg [2:0] current_state, next_state;

    // Packet buffer
    reg [15:0] packet_buffer [0:5];

    // FSM variables
    logic [7:0] header;
    logic [15:0] num1, num2, opcode, checksum;
    logic valid_packet;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S_IDLE;
            packet_buffer <= 0;
            valid_packet <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // State transition assignments
    always @(current_state or rx_valid_i or rx_data_8_i) begin
        case (current_state)
            S_IDLE: begin
                if (rx_valid_i) begin
                    if (rx_data_8_i == 16'hBACD) begin
                        next_state <= S_GOT_8_BYTES;
                        packet_buffer <= rx_data_8_i;
                    end else begin
                        valid_packet <= 0;
                    end
                end
            end
            S_GOT_8_BYTES: begin
                packet_buffer <= {packet_buffer[4:0], rx_data_8_i};
                if (rx_data_8_i == 16'hBACD) begin
                    next_state <= S_RECV_CHECKSUM;
                end else begin
                    valid_packet <= 0;
                end
            end
            S_RECV_CHECKSUM: begin
                header = packet_buffer[15:8];
                num1 = packet_buffer[11:4];
                num2 = packet_buffer[9:0];
                opcode = packet_buffer[7];
                checksum = packet_buffer[6] + packet_buffer[5] + packet_buffer[4] + packet_buffer[3] + packet_buffer[2] + packet_buffer[1] + packet_buffer[0];
                if (header == 16'hBACD && (checksum == 0)) begin
                    next_state <= S_BUILD_RESPONSE;
                end else begin
                    next_state <= S_IDLE;
                end
            end
            S_BUILD_RESPONSE: begin
                num1 <= num1;
                num2 <= num2;
                opcode <= opcode;
                // Calculate checksum for response packet
                checksum = num1 + num2 + 8'h01;
                if (checksum == 0) begin
                    next_state <= S_SEND_FIRST_BYTE;
                end else begin
                    next_state <= S_IDLE;
                end
            end
            S_SEND_FIRST_BYTE: begin
                tx_start_o = 1'b1;
                tx_data_8_o <= 16'hABCD;
                tx_data_8_o <= num1;
                next_state <= S_RESPONSE_READY;
            end
            S_RESPONSE_READY: begin
                tx_start_o = 1'b0;
                tx_data_8_o <= num1 + num2;
                next_state <= S_IDLE;
            end
            default: next_state <= S_IDLE;
        endcase
    end

    // Output logic
    assign tx_start_o = current_state == S_SEND_FIRST_BYTE;
    always @(posedge clk) begin
        if (current_state == S_RESPONSE_READY) begin
            tx_data_8_o <= num1 + num2;
        end
    end

endmodule
