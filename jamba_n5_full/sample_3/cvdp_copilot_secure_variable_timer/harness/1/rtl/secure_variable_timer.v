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
    reg [3:0] count;
    reg is_counting;
    reg is_done;
    reg o_processing;
    reg o_completed;

    always @(posedge i_clk) begin
        if (i_rst_n) begin
            o_processing <= 0;
            o_completed <= 0;
            o_time_left <= 15;
            delay <= 0;
            count <= 0;
            is_counting <= 0;
            is_done <= 0;
            state <= Idle;
        end else begin
            state <= case (state)
                Idle: begin
                    if (i_data_in == "1101") begin
                        state <= Configure;
                    end
                end
                Configure: begin
                    if (i_data_in[3:0] == "0110") begin
                        state <= Counting;
                    end
                end
                Counting: begin
                    is_counting <= 1;
                    if (count == (delay[3:0] + 1) * 1000) begin
                        o_completed <= 1;
                        state <= Done;
                    end else begin
                        o_time_left = delay[3:0] + 1;
                        o_time_left = o_time_left - 1;
                        count <= count + 1;
                    end
                end
                Done: begin
                    o_processing <= 0;
                    o_completed <= 1;
                    state <= Idle;
                end
                default: state <= Idle;
            endcase;
        end
    end

endmodule
