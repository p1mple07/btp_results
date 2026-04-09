module event_scheduler (
    input logic clk,
    input logic reset,
    input logic [3:0] add_event,
    input logic [3:0] cancel_event,
    input logic [3:0] event_id,
    input logic [15:0] timestamp,
    input logic [3:0] priority_in,
    output logic [3:0] event_triggered,
    output logic [15:0] triggered_event_id,
    output logic error,
    output logic [15:0] current_time
);

    localparam MAX_EVENTS = 16;
    localparam TIMESTAMP_WIDTH = 16;
    localparam PRIORITY_WIDTH = 4;
    localparam TIME_INCREMENT = 10'd10;

    reg [TIMESTAMP_WIDTH-1:0] tmp_event_timestamps [0:MAX_EVENTS-1];
    reg [TIMESTAMP_WIDTH-1:0] tmp_event_priorities [0:MAX_EVENTS-1];
    reg [TIMESTAMP_WIDTH-1:0] tmp_event_valid [0:MAX_EVENTS-1];
    reg [3:0] current_time_local;

    always @(posedge clk) begin
        if (reset) begin
            current_time_local <= 0;
            tmp_event_timestamps[0:MAX_EVENTS-1] = 0;
            tmp_event_priorities[0:MAX_EVENTS-1] = 0;
            tmp_event_valid[0:MAX_EVENTS-1] = 1;
        end else begin
            current_time_local = current_time_local + TIME_INCREMENT;
        end
    end

    always @(*) begin
        if (add_event) begin
            // Try to find a free slot
            for (int i = 0; i < MAX_EVENTS; i = i + 1) begin
                if (!tmp_event_valid[i]) begin
                    tmp_event_timestamps[i] = current_time_local;
                    tmp_event_priorities[i] = priority_in;
                    tmp_event_valid[i] = 1;
                    break;
                end
            end
            if (i == MAX_EVENTS) error = 1;
        end else if (cancel_event) begin
            // Cancel the event
            if (event_triggered && triggered_event_id == event_id) begin
                event_triggered = 0;
                triggered_event_id = 0;
                error = 0;
            end else begin
                error = 1;
            end
        end else if (event_triggered) begin
            // Check for matching current time
            if (current_time_local == tmp_current_time) begin
                event_triggered = 0;
                triggered_event_id = triggered_event_id;
            end
        end
    end

endmodule
