module packet_controller(
    input logic clk,
    input logic rst,
    input logic rx_valid_i,
    input logic [7:0] rx_data_8_i,
    input logic tx_done_tick_i,
    output logic tx_start_o,
    output logic [7:0] tx_data_8_o
);
    
    // Define states
    typedef enum {
        S_IDLE,
        S_GOT_8_BYTES,
        S_RECV_CHECKSUM,
        S_BUILD_RESPONSE,
        S_SEND_FIRST_BYTE,
        S_RESPONSE_READY
    } state_t;
    
    // Declare internal signals
    logic [15:0] header;
    logic [15:0] payload;
    logic [7:0] opcode;
    logic [7:0] checksum;
    state_t state;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            // Initialize internal signals
            header <= 16'd0;
            payload <= 16'd0;
            opcode <= 8'd0;
            checksum <= 8'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (rx_valid_i && rx_data_8_i == 16'hBACD) begin
                        state <= S_GOT_8_BYTES;
                        // Load header into internal signals
                        header <= {rx_data_8_i[15:8], rx_data_8_i[7:0]};
                    end
                end
                S_GOT_8_BYTES: begin
                    // Accumulate payload bytes
                    payload <= {payload[15:8], rx_data_8_i};
                    // Calculate checksum
                    checksum <= $unsigned(checksum) + rx_data_8_i;
                    // Check for complete packet
                    if (payload == 16'd0) begin
                        state <= S_RECV_CHECKSUM;
                        // Extract opcode from header
                        opcode <= header[7:0];
                    end
                end
                S_RECV_CHECKSUM: begin
                    // Compute checksum and check against header
                    if ($unsigned(checksum)!= header[15:8]) begin
                        state <= S_IDLE;
                    end else begin
                        state <= S_BUILD_RESPONSE;
                    end
                end
                S_BUILD_RESPONSE: begin
                    // Compute result based on opcode
                    payload <= opcode == 8'd0? payload + payload : payload - payload;
                    // Update state for next iteration
                    state <= S_SEND_FIRST_BYTE;
                end
                S_SEND_FIRST_BYTE: begin
                    // Send first byte of response
                    tx_start_o <= 1'b1;
                    tx_data_8_o <= payload[7:0];
                    state <= S_RESPONSE_READY;
                end
                S_RESPONSE_READY: begin
                    // Continue transmission of remaining bytes
                    if (tx_done_tick_i) begin
                        state <= S_IDLE;
                    end
                end
            endcase
        end
    end
    
endmodule