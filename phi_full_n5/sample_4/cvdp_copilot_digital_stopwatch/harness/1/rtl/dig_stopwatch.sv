module dig_stopwatch #(parameter CLK_FREQ=50000000)
(
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    // Internal clock divider
    reg [25:0] clk_counter;
    reg [2:0] divider = 3'b000; // Initial divider value

    // Counter for seconds
    reg [5:0] sec_counter = 0;

    // Counter for minutes
    reg [5:0] min_counter = 0;

    // Counter for hours
    reg [1:0] hr_counter = 0;

    // Clock divider to produce one-second pulse
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 0;
            sec_counter <= 0;
            min_counter <= 0;
            hr_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter >= CLK_FREQ / 1000000) begin
                clk_counter <= 0;
                sec_counter <= sec_counter + 1;
                if (sec_counter >= 60) begin
                    sec_counter <= 0;
                    min_counter <= min_counter + 1;
                    if (min_counter >= 60) begin
                        min_counter <= 0;
                        hr_counter <= hr_counter + 1;
                    end
                end
            end
        end
    end

    // Update hour signal
    always @(posedge clk_counter) begin
        if (hr_counter == 1) begin
            hour <= 1;
            hr_counter <= 0;
        end
    end

    // Reset logic
    always @(posedge reset) begin
        sec_counter <= 0;
        min_counter <= 0;
        hour <= 0;
    end

    // Start/Stop logic
    always @(posedge clk) begin
        if (start_stop) begin
            sec_counter <= 0;
            min_counter <= 0;
            hour <= 0;
        end
    end

endmodule
