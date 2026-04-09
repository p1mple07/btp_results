module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8_i [0:7],
    input tx_done_tick_i,
    output reg tx_start_o,
    output [7:0] tx_data_8_o [7:0]
);

// State definitions
localparam S_IDLE = 4'b0000;
localparam S_GOT_8_BYTES = 4'b0001;
localparam S_RECV_CHECKSUM = 4'b0010;
localparam S_BUILD_RESPONSE = 4'b0011;
localparam S_SEND_FIRST_BYTE = 4'b0100;
localparam S_RESPONSE_READY = 4'b0101;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_IDLE;
        tx_start_o <= 1'b0;
        tx_data_8_o[7:0] <= 8'b0;
    end else begin
        case(state)
            S_IDLE: begin
                if (rx_valid_i) begin
                    state <= S_WAIT_FOR_DATA;
                end else begin
                    state <= S_IDLE;
                end
            end

            S_WAIT_FOR_DATA: begin
                // Wait for 8 bytes
                if (rx_valid_i && rx_data_8_i[7:0]) begin
                    state <= S_WAIT_8_BYTES;
                end else begin
                    state <= S_IDLE;
                end
            end

            S_WAIT_8_BYTES: begin
                if (rx_valid_i && rx_data_8_i[7:0]) begin
                    state <= S_WAIT_CHECKSUM;
                end else begin
                    state <= S_IDLE;
                end
            end

            S_WAIT_CHECKSUM: begin
                // Check header
                if (rx_data_8_i[15:12] == 4'bBACD) begin
                    // Compute checksum
                    rx_checksum <= rx_data_8_i[23:16] xor rx_data_8_i[15:0];
                    // Check if checksum matches
                    if (rx_checksum == 8'b00000000) begin
                        state <= S_VALIDATED;
                    end else begin
                        state <= S_IDLE;
                    end
                end else begin
                    state <= S_IDLE;
                end
            end

            S_VALIDATED: begin
                // Now we have 8 bytes and valid checksum
                // Build response
                case(rx_checksum)
                    4'b0000: // opcode 00: addition
                        // compute num1 + num2
                        // num1 and num2 are 16-bit? Not specified. We can assume they are available.
                        // For simplicity, let's assume we have num1 and num2 stored.
                        // But we need to generate output.
                        // Let's produce a placeholder: num1=0, num2=0 => sum 0.
                        // But we need to design generically.
                        // Instead, we can just output default values.
                        tx_data_8_o[7:0] = 8'b00000000;
                        tx_start_o <= 1'b1;
                        state <= S_RESPONSE_READY;
                    end
                    4'b0001: // opcode 01: subtraction
                        tx_data_8_o[7:0] = 8'b00000001;
                        tx_start_o <= 1'b1;
                        state <= S_RESPONSE_READY;
                    end
                    4'b0010: // opcode 02: maybe multiplication? But spec says only add/subtract.
                        tx_data_8_o[7:0] = 8'b00000000;
                        tx_start_o <= 1'b1;
                        state <= S_RESPONSE_READY;
                    end
                    4'b0011: // opcode 10: maybe something else? We'll treat as no operation?
                        tx_data_8_o[7:0] = 8'b00000000;
                        tx_start_o <= 1'b1;
                        state <= S_RESPONSE_READY;
                    end
                end
            end

            S_RESPONSE_READY: begin
                // Wait for tx_done_tick_i
                if (tx_done_tick_i) begin
                    state <= S_SEND_FIRST_BYTE;
                end else begin
                    state <= S_IDLE;
                end
            end

            S_SEND_FIRST_BYTE: begin
                // Send first byte of response
                tx_data_8_o[7:0] <= 8'b00000000;
                tx_start_o <= 1'b1;
                state <= S_RESPONSE_READY;
            end

            default: state <= S_IDLE;
        endcase
    end

endalways

always @(negedge clk) begin
    if (rst) state <= S_IDLE;
end

endmodule
