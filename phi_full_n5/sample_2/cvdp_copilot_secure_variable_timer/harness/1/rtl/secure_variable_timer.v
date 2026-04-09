
module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Internal registers
    reg [3:0] delay;            // Holds the 4-bit delay value
    reg [3:0] counter;          // Counter for counting cycles
    reg [3:0] current_delay;    // Current delay value being counted

    // State machine (FSM) definitions
    localparam IDLE = 0;
    localparam CONFIGURE = 1;
    localparam COUNT = 2;
    localparam DONE = 3;

    // State register
    reg [2:0] state;

    // Input and output logic
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            counter <= 0;
            current_delay <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (i_data_in == 4'b1101) begin
                        state <= CONFIGURE;
                        counter <= 0;
                    end
                end
                CONFIGURE: begin
                    if (i_data_in[3:0] != 4'b0000) begin
                        delay <= i_data_in[3:0];
                        state <= COUNT;
                    end
                end
                COUNT: begin
                    counter <= counter + 1;
                    if (counter >= delay + 999) begin
                        o_processing <= 1;
                        o_time_left <= current_delay - (counter - (delay + 999));
                        state <= DONE;
                    end
                end
                DONE: begin
                    o_completed <= 1;
                    if (i_ack) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Delay value logic
    always @(posedge i_clk) begin
        if (state == COUNT) begin
            current_delay <= current_delay - 1;
            if (current_delay == 0) begin
                state <= DONE;
                counter <= 0;
            end
        end
    end

endmodule

