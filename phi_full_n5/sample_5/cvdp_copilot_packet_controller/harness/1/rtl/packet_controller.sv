module packet_controller (
    input clk,
    input rst,
    input rx_valid_i,
    input [7:0] rx_data_8,
    input tx_done_tick_i,
    output reg tx_start_o,
    output reg [7:0] tx_data_8
);

    // Define states
    typedef enum'(wire [1:0] state) state_t;
    parameter S_IDLE = 2'b00,
              S_GOT_8_BYTES = 2'b01,
              S_RECV_CHECKSUM = 2'b10,
              S_BUILD_RESPONSE = 2'b11,
              S_SEND_FIRST_BYTE = 3'b000,
              S_RESPONSE_READY = 3'b001;

    // FSM registers
    reg [1:0] fsm;
    reg [7:0] buffer [5:0];
    reg [7:0] response_data [7:0];
    reg [7:0] checksum [7:0];
    reg [7:0] result;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            fsm <= S_IDLE;
        else
            fsm <= fsm + 1;
    end

    // State-specific logic
    always @(fsm, rx_valid_i, rx_data_8) begin
        case (fsm)
            S_IDLE: begin
                if (rx_valid_i) begin
                    buffer[0] <= rx_data_8;
                end
            end
            S_GOT_8_BYTES: begin
                if (rx_valid_i) begin
                    buffer[1] <= rx_data_8;
                end else begin
                    fsm <= S_IDLE;
                end
            end
            S_RECV_CHECKSUM: begin
                if (!rx_valid_i) begin
                    fsm <= S_IDLE;
                end else begin
                    checksum[0] <= (buffer[0] + buffer[1]) % 256;
                    if (buffer[2] == 16'hBACD && checksum[0] == 0) begin
                        fsm <= S_BUILD_RESPONSE;
                    end else begin
                        fsm <= S_IDLE;
                    end
                end
            end
            S_BUILD_RESPONSE: begin
                response_data[0] <= 16'hABCD;
                if (fsm == S_BUILD_RESPONSE) begin
                    if (opcode == 8'h00) begin
                        result <= buffer[0] + buffer[1];
                    end else if (opcode == 8'h01) begin
                        result <= buffer[0] - buffer[1];
                    end
                end
                response_data[1] <= result;
                response_data[2] <= 8'hopcode;
                response_data[3] <= checksum[1];
                response_data[4] <= checksum[2];
                response_data[5] <= checksum[3];
                response_data[6] <= checksum[4];
                response_data[7] <= checksum[5];
                fsm <= S_SEND_FIRST_BYTE;
            end
            S_SEND_FIRST_BYTE: begin
                tx_start_o <= 1'b1;
                tx_data_8 <= response_data[0];
                if (tx_done_tick_i) begin
                    fsm <= S_RESPONSE_READY;
                end
            end
            S_RESPONSE_READY: begin
                tx_start_o <= 1'b0;
                if (fsm == S_RESPONSE_READY) begin
                    for (int i = 1; i < 5; i = i + 1) begin
                        tx_data_8 <= response_data[i];
                    end
                    fsm <= S_IDLE;
                end
            end
            default: fsm <= S_IDLE;
        endcase
    end

endmodule
