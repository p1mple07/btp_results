
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
    reg [3:0] counter;          // Counter for the total clock cycles
    reg [3:0] time_left;        // Remaining time during the counting phase
    reg state, next_state;      // FSM state

    // State assignments
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= 0;
            counter <= 0;
            time_left <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(state or i_data_in or i_ack) begin
        case (state)
            0: begin
                if (i_data_in == 4'b1101) begin
                    state <= 1;
                    delay <= i_data_in;
                end else begin
                    state <= 0;
                end
            end
            1: begin
                if (i_data_in == 4'b0000) begin
                    state <= 2;
                end else begin
                    state <= 0;
                end
            end
            2: begin
                if (!i_ack) begin
                    state <= 3;
                    counter <= 0;
                end else begin
                    state <= 0;
                end
            end
            3: begin
                if (counter < delay + 1) begin
                    counter <= counter + 1;
                    if (counter >= delay + 1) begin
                        time_left <= delay;
                    end
                end else begin
                    state <= 4;
                end
            end
            4: begin
                o_processing <= 1;
                o_completed <= 1;
                state <= 0;
            end
            default: state <= 0;
        end
    end

    // Counting logic
    always @(posedge i_clk) begin
        if (state == 3) begin
            if (counter >= delay + 1) begin
                time_left <= time_left - 1;
                if (time_left == 0) begin
                    counter <= counter - 1;
                end
            end
        end
    end

endmodule

