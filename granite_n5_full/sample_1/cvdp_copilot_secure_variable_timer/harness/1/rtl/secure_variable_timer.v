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
    reg [3:0] count;            // Holds the current count value
    reg [3:0] temp;             // Temporary storage register

   always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            delay <= 4'b0;
            count <= 4'b0;
            temp <= 4'b0;
            o_time_left <= 4'b0;
            o_processing <= 1'b0;
            o_completed <= 1'b0;
        end else begin
            if (i_data_in == 1'b1) begin
                if (delay == 4'b0 && i_data_in == 1'b1) begin
                    temp <= {1'b0, i_data_in};
                    delay <= {temp[2:0], 1'b0};
                end
                if (i_data_in!= 1'b1) begin
                    temp <= {temp[2:0], i_data_in};
                    delay <= {temp[2:0], 1'b0};
                end
            end
            if (i_data_in == 1'b0) begin
                if (delay > 4'b0) begin
                    count <= count + 1;
                    if (count == delay + 1) begin
                        o_time_left <= 4'b0;
                        o_processing <= 1'b0;
                        o_completed <= 1'b1;
                    end
                end
            end
        end
    end

    assign o_time_left = count;
    assign o_processing = (delay > 4'b0);

endmodule