
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
    reg [3:0] counter;          // Counter for the 1000-cycle count
    reg [3:0] time_left;        // Temporary storage for time_left during counting
    reg [3:0] state;            // State machine

    // State encoding
    localparam IDLE = 4'b0000,
            CONFIGURE = 4'b0001,
            COUNT = 4'b0010,
            DONE = 4'b0100;

    // State transition logic
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            state <= IDLE;
        else
            case (state)
                IDLE: begin
                    if (i_data_in == 4'b1101) begin
                        state <= CONFIGURE;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                CONFIGURE: begin
                    delay <= i_data_in;
                    state <= COUNT;
                end
                COUNT: begin
                    counter <= counter + 4'b0001;
                    if (counter == (delay + 4'b0001) - 1) begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    o_processing <= 1;
                    o_time_left <= time_left;
                    if (i_ack) begin
                        state <= IDLE;
                    end
                end
            endcase
    end

    // Counting logic
    always @(state, i_data_in, counter) begin
        case (state)
            CONFIGURE: begin
                time_left <= delay;
            end
            COUNT: begin
                time_left <= time_left - 1;
                if (time_left == 0) begin
                    state <= DONE;
                end
            end
        endcase
    end

endmodule

