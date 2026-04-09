`timescale 1ns/1ps
module event_scheduler (
    input logic clk,
    input logic reset,
    input logic [3:0] add_event,
    input logic [3:0] cancel_event,
    input logic [3:0] event_id,
    input logic [15:0] timestamp,
    input logic [3:0] priority_in,
    output logic event_triggered,
    output logic [3:0] triggered_event_id,
    output logic error,
    output logic [15:0] current_time
);

    reg clk;
    reg reset;
    reg [3:0] event_id_temp;
    reg [15:0] timestamp_temp;
    reg [3:0] priority_in_temp;
    reg [15:0] event_triggered_temp;
    reg [3:0] triggered_event_id_temp;
    reg [15:0] current_time_temp;
    reg event_valid;

    always @(posedge clk) begin
        if (reset) begin
            event_timestamps[0 .. 15] = 0;
            event_priorities[0 .. 15] = 0;
            event_valid[0 .. 15] = 1'b1;
            current_time_temp = 0;
            current_time = current_time_temp;
            event_triggered_temp = 0;
            triggered_event_id_temp = 0;
            error_temp = 0;
        end else begin
            event_timestamps[event_id] = timestamp;
            event_priorities[event_id] = priority_in;
            event_valid[event_id] = 1'b1;
            current_time_temp = current_time + 10;
            current_time = current_time_temp;
        end
    end

    always @(*) begin
        event_triggered_temp = 0;
        triggered_event_id_temp = 0;
        current_time_temp = 0;

        for (int i = 0; i < 16; i++) begin
            if (event_valid[i] && event_timestamps[i] <= current_time) begin
                event_triggered_temp = event_id_temp[i];
                triggered_event_id_temp = i;
                current_time_temp = current_time - event_timestamps[i];
                break;
            end
        end

        event_triggered = event_triggered_temp;
        triggered_event_id = triggered_event_id_temp;
        error = 0;

        if (event_triggered) begin
            current_time = current_time_temp - 10;
        end
    end

    assign current_time = current_time_temp;

endmodule
