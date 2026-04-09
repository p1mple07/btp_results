module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input rx_data_8_i [7:0],
    input tx_done_tick_i,
    output reg tx_start_o,
    output reg [7:0] tx_data_8_o
);

reg [3:0] state;
reg buffer;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_IDLE;
        buffer <= 8'b0;
        tx_start_o = 0;
        tx_data_8_o = 8'b0;
    end else begin
        case (state)
            S_IDLE: begin
                if (rx_valid_i && rx_data_8_i[7:0] == 8'bBACD) begin
                    state <= S_GOT_8_BYTES;
                end
            end

            S_GOT_8_BYTES: begin
                buffer = rx_data_8_i;
                if (buffer[7:0] == 8'bBACD) begin
                    state <= S_RECV_CHECKSUM;
                end else begin
                    state <= S_IDLE;
                end
            end

            S_RECV_CHECKSUM: begin
                localvar sum = 0;
                for (int i = 0; i < 8; i=i+1) begin
                    sum += buffer[i];
                end

                if (sum % 256 != 0) begin
                    state <= S_IDLE;
                    break;
                end else begin
                    state <= S_BUILD_RESPONSE;
                end
            end

            S_BUILD_RESPONSE: begin
                // Opcode 00 for addition
                localvar opcode = 8'h00;
                localvar num1 = 8'h1234; // example value
                localvar num2 = 8'h5678;
                localvar checksum = sum;

                tx_start_o = 1;
                tx_data_8_o = {num1, num2, opcode, checksum};
            end

            S_SEND_FIRST_BYTE: begin
                // Not required for our state machine
            end

            default: state <= S_IDLE;
        endcase
    end
endclock;

endmodule
