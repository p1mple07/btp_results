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
    reg [3:0] counter;
    reg counting_active;

    always @(i_clk) begin
        if (i_rst_n) begin
            o_time_left <= 4'd4'b0000;
            o_processing <= 1'b0;
            o_completed <= 1'b0;
            delay <= 4'd0;
            counter <= 4'd0;
            counting_active <= 1'b0;
        end else begin
            // Check for 1101 on i_data_in
            if (i_data_in == 4'b1101) begin
                // Start of delay sequence
                counter <= 4'd0;
                counting_active = 1'b1;
            end else if (counter == 4'd0) begin
                // Read next 4 bits
                if (i_data_in[3:0] == 4'b0110) begin
                    delay[3:0] = 4'b0110;
                end else if (i_data_in[3:0] == 4'b1011) begin
                    delay[3:0] = 4'b1011;
                end else begin
                    // ignore
                end
            end

            // Counting phase
            if (counting_active) begin
                counter <= counter + 1;
                if (counter == 8'b10000000) begin // after 1000 cycles? Actually, 4 bits + 1?
                    // Instead, we can use a loop
                    // But we can use a counter that increments and triggers on full cycle.
                    // We'll use a counter that when it equals 8'b10000000, it means we've counted all.
                    // But we can use a simpler approach: just increment until counter reaches a value.
                    // However, for the purpose, we can just do a counter that increments and then at the end asserts o_completed.
                end
            end

            // Outputs
            if (o_processing) begin
                o_time_left = delay;
            end else begin
                o_time_left = 4'd4'b0000;
            end

            if (o_completed) begin
                o_completed <= 1'b0;
                counting_active <= 1'b0;
            end

            // Idle state: if no 1101, keep idle.
            if (!counting_active) begin
                if (i_data_in == 4'b1101) begin
                    counter <= 4'd0;
                    counting_active = 1'b1;
                end
            end
        end
    end

endmodule
