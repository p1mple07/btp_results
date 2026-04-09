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
    reg [3:0] countdown;        // Countdown timer
    reg state;                  // State machine state (Idle, Configure Delay, Counting, Done)
    reg pattern_state;          // State for pattern detection (0-4)
    reg [3:0] pattern_next;     // Next expected bit for pattern detection

    // FSM for pattern detection
    always @ (posedge i_clk)
    begin
        if (state == Idle) begin
            if (i_data_in & 1) begin
                pattern_state = 1;
            end else begin
                pattern_state = 0;
            end
        end else if (state == pattern_state) begin
            if (i_data_in & 1) begin
                case (pattern_state)
                    0: pattern_state = 1;
                    1: pattern_state = 2;
                    2: pattern_state = 3;
                    3: pattern_state = 4;
                end else begin
                    pattern_state = 0;
                end
            end
        end else if (state == Configure Delay) begin
            // Code for handling data during configuration phase
        end else if (state == Counting) begin
            countdown = countdown - 1;
        end else if (state == Done) begin
            // Code for handling acknowledgment
        end
    end

    // State machine implementation
    always @ (posedge i_clk)
    begin
        case (state)
            Idle:
                if (i_data_in & 1) begin
                    if (pattern_state == 4) begin
                        state = Configure Delay;
                    end else begin
                        state = pattern_state == 0 ? pattern_state + 1 : pattern_state;
                    end
                end else begin
                    state = 0;
                end
                // If pattern_state is 4, transition to Configure Delay
                if (pattern_state == 4) begin
                    state = Configure Delay;
                end
                // If pattern_state is not 4, transition to next state
                else if (pattern_state == 0) begin
                    state = pattern_state + 1;
                end else if (pattern_state == 1) begin
                    state = 2;
                end else if (pattern_state == 2) begin
                    state = 3;
                end else if (pattern_state == 3) begin
                    state = 4;
                end
            // ... (other states)
        end
    end

    // Configuration phase
    when (state == Configure Delay)
        if (i_data_in & 1) begin
            // Code to shift data into delay register
        end else begin
            // Code to handle data during configuration phase
        end

    // Counting phase
    when (state == Counting)
        countdown = countdown - 1;

    // Done phase
    when (state == Done)
        if (i_ack & 1) begin
            state = Idle;
        end else begin
            // Code to handle completion without acknowledgment
        end
    endcase

    // Output assignments
    o_processing = (state == Counting);
    o_completed = (state == Done);

    // Reset handling
    if (i_rst_n) begin
        state = Idle;
        // Reset other registers
        delay = 0;
        countdown = 0;
    end