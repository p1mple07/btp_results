module uart_rx_to_axis #(
    parameter CLK_FREQ = 100,
    parameter BIT_RATE = 115200,
    parameter BIT_PER_WORD = 8,
    parameter PARITY_BIT = 0,
    parameter STOP_BITS_NUM = 1
)(
    input aclk,
    input aresetn,
    input rx,
    output reg [7:0] tdata,
    output reg tuser,
    output reg tvalid
);

// Parameters
localparam CLK_CYC = 1 / CLK_FREQ; // cycle per clock cycle.
localparam CLOCK_PERIOD = CLK_CYC * CLK_FREQ; // total clock cycles for one bit period.

// Internal state variables
reg [BIT_COUNT-1:0] bit_count;
reg [BIT_PER_WORD-1:0] data_register;
reg [2:0] state;
reg last_state;
reg enable_bit;

always @(posedge aclk or posedge aresetn) begin
    if (aresetn) begin
        bit_count <= 0;
        data_register <= 0;
        state <= IDLE;
        last_state = state;
        enable_bit <= 1'b0;
    end else begin
        case(state)
            IDLE: begin
                if (rx && !aclk.falling) begin
                    state <= START;
                end
            end
            START: begin
                state <= DATA;
                enable_bit <= 1'b1;
            end
            DATA: begin
                // sample data bits
                // ... but we don't need to show bit sampling in detail
                // We just update state.
                state <= PARITY;
            end
            PARITY: begin
                // sample parity bit
                if (parity_bit == 2) begin
                    // even parity: XOR all bits
                    data_register = xor_bits(data_register, data_register);
                end else begin
                    // odd parity: XOR all bits except last
                    data_register = xor_bits(data_register, data_register[BIT_COUNT-1]);
                end
                // compute expected parity
                if (PARITY_BIT) begin
                    data_register = xor(data_register, expected_parity);
                end
                if (data_register != expected_parity) begin
                    tuser <= 1'b1;
                end else begin
                    tuser <= 1'b0;
                end
            end
            STOP1: begin
                state <= STOP2;
            end
            STOP2: begin
                // sample second stop bit
                if (stop_bit == 1'b1) begin
                    // assert stop bit ok
                end else begin
                    tuser <= 1'b1;
                end
                state <= OUT_RDY;
            end
            OUT_RDY: begin
                tvalid <= 1'b1;
                tdata <= data_register;
                // reset to idle
                state <= IDLE;
            end
        endcase
    end
endelse

// Clock counter for bit period
always @(*) begin
    bit_count <= bit_count + 1;
    if (bit_count == CLOCK_PERIOD) begin
        bit_count <= 0;
        last_state = state;
    end
end

endmodule
