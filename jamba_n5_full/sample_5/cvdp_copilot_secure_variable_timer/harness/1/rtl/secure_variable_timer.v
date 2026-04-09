module secure_variable_timer (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_data_in,
    output reg [3:0] o_time_left,
    output reg o_processing,
    output reg o_completed,
    input wire i_ack
);

    reg [3:0] delay;
    reg [3:0] temp;
    reg count;
    reg o_processing_flag;
    reg o_completed_flag;
    reg o_time_left_valid;

    always @(i_clk) begin
        if (!i_rst_n) begin
            o_time_left_valid = 1'b0;
            delay = 0;
            temp = 0;
            o_processing_flag = 0;
            o_completed_flag = 0;
            o_time_left = 4'hFFFF;
            o_processing = 0;
            o_completed = 0;
            o_ack = 1'b1;
            return;
        end

        // Detect 1101 sequence
        if (i_data_in == 4'b1101) begin
            // Set state to Configure
            state <= Configure;
        end else begin
            state <= Idle;
        end
    end

    always @(state) begin
        case (state)
            Idle: begin
                // Search for 1101
                if (i_data_in == 4'b1101) begin
                    state <= Configure;
                end else begin
                    state <= Idle;
                end
            end

            Configure: begin
                if (i_data_in == 4'b1101) begin
                    // Read 4 bits
                    temp = i_data_in[3:0];
                    state <= Counting;
                end else begin
                    state <= Idle;
                end
            end

            Counting: begin
                // Count for (delay[3:0]+1)*1000 cycles
                if (count < (delay[3:0] + 1) * 1000) begin
                    count++;
                    if (count == (delay[3:0] + 1) * 1000) begin
                        o_completed = 1;
                        o_processing = 0;
                        o_time_left_valid = 1'b1;
                    end else begin
                        o_time_left_valid = 1'b0;
                    end
                end else begin
                    o_completed = 0;
                    o_processing = 0;
                    o_time_left_valid = 1'b0;
                    count = 0;
                end
            end

            Done: begin
                o_completed_flag = 1;
                o_time_left = 4'hFFFF; // reset to don't care
                o_processing = 0;
                o_completed = 0;
                o_ack = 1'b0;
                return;
            end
        endcase
    end

endmodule
