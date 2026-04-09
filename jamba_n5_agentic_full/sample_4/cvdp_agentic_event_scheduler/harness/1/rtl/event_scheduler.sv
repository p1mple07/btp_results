module event_scheduler (
    input clk,
    input reset,
    input [3:0] add_event,
    input [3:0] cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    output reg event_triggered,
    output reg triggered_event_id,
    output reg error,
    output reg [15:0] current_time
);

    reg [15:0] current_time;
    reg [15:0] tmp_current_time;
    reg [15:0] tmp_event_timestamps;
    reg [15:0] tmp_event_priorities;
    reg [15:0] tmp_event_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_time = 0;
            tmp_current_time = 0;
            tmp_event_timestamps = 16'b0;
            tmp_event_priorities = 16'b0;
            tmp_event_valid = 16'b1;
        end else begin
            current_time = current_time + 10'd1;
        end
    end

    always @(posedge clk) begin
        if (add_event) begin
            if (event_timestamps[event_id] == 16'b0) begin
                event_timestamps[event_id] = timestamp;
                event_priorities[event_id] = priority_in;
                event_valid[event_id] = 1'b1;
            end else begin
                error = 1'b1;
            end
        end

        if (cancel_event) begin
            if (event_timestamps[event_id] == timestamp) begin
                event_timestamps[event_id] = 0;
                event_priorities[event_id] = 0;
                event_valid[event_id] = 1'b0;
            end else begin
                error = 1'b1;
            end
        end

        if (event_triggered) begin
            event_triggered = 1'b0;
            triggered_event_id = 0;
            error = 1'b0;

            // Find the highest priority event that is valid
            assign current_time = current_time + 10'd1;

            for (int i = 0; i < 16; i = i + 1) begin
                if (event_valid[i] && event_timestamps[i] <= current_time) begin
                    if (event_priorities[i] > (priority_in ^ 15'hF)) begin
                        event_triggered = 1'b1;
                        triggered_event_id = event_id;
                        break;
                    end
                end
            end

            if (!event_triggered) error = 1'b1;
        end
    end

endmodule
