module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i,
    input tx_done_tick_i,
    output reg tx_start_o
);

    // Define state register and input/output ports
    reg [1:0] state, next_state;
    reg [7:0] buffer [5:0];
    reg [7:0] num1, num2, opcode, checksum_out;
    wire valid_checksum;

    // Constants for packet header and fixed response header
    localparam S_IDLE = 2'b00,
              S_GOT_8_BYTES = 2'b01,
              S_RECV_CHECKSUM = 2'b10,
              S_BUILD_RESPONSE = 2'b11,
              S_SEND_FIRST_BYTE = 3'b000,
              S_RESPONSE_READY = 3'b001;

    const uint header_expected = 32'hBACD;
    const uint response_header = 32'hABCD;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // State flip-flop
    always @(state) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (rx_valid_i) begin
                    buffer[0] <= rx_data_8_i;
                    next_state <= S_GOT_8_BYTES;
                end
                else
                    next_state <= S_IDLE;
            end
            S_GOT_8_BYTES: begin
                buffer[1] <= rx_data_8_i;
                next_state <= S_RECV_CHECKSUM;
            end
            S_RECV_CHECKSUM: begin
                if (buffer[1] == header_expected) begin
                    buffer[2] <= rx_data_8_i;
                    buffer[3] <= rx_data_8_i;
                    buffer[4] <= rx_data_8_i;
                    next_state <= S_BUILD_RESPONSE;
                end
                else
                    next_state <= S_IDLE;
            end
            S_BUILD_RESPONSE: begin
                opcode = buffer[2];
                num1 = buffer[3];
                num2 = buffer[4];
                checksum_out = compute_checksum(num1, num2, opcode);
                if (checksum_out == 0) begin
                    tx_start_o <= 1;
                    next_state <= S_SEND_FIRST_BYTE;
                end
                else
                    next_state <= S_IDLE;
            end
            S_SEND_FIRST_BYTE: begin
                buffer[0] <= response_header;
                buffer[1] <= num1;
                buffer[2] <= num2;
                buffer[3] <= opcode;
                buffer[4] <= checksum_out;
                tx_start_o <= 0;
                next_state <= S_RESPONSE_READY;
            end
            S_RESPONSE_READY: begin
                // Transmission logic would go here
                next_state <= S_IDLE;
            end
        end
    end

    // Checksum computation function
    function uint compute_checksum(uint a, uint b, uint opcode);
        case (opcode)
            8'h00: compute_checksum = a + b;
            8'h01: compute_checksum = a - b;
            default: compute_checksum = 0;
        endcase
        return (compute_checksum) % 256;
    endfunction

    // Output logic
    assign tx_start_o = state == S_SEND_FIRST_BYTE;
    assign buffer[5] = valid_checksum; // Assuming valid_checksum is computed elsewhere

endmodule
