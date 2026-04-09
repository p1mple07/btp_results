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
    reg clk_counter;
    reg o_processing_tmp;

    // --------- State Machine ----------
    localparam IDLE = 4'd0;
    localparam CONFIGURE = 4'd1;
    localparam COUNTING = 4'd2;
    localparam DONE = 4'd3;

    always @(posedge i_clk) begin
        if (i_rst_n) begin
            state <= IDLE;
            delay <= 0;
            o_time_left <= 4'd1000;
            o_processing <= 1'b0;
            o_completed <= 1'b0;
            return;
        end

        case (state)
            IDLE: begin
                if (i_data_in == "1101") begin
                    state <= CONFIGURE;
                end
            end

            CONFIGURE: begin
                if (i_data_in[3] == '1') begin
                    if (i_data_in[2] == '1') begin
                        if (i_data_in[1] == '1') begin
                            if (i_data_in[0] == '1') begin
                                state <= COUNTING;
                            end;
                        end else end;
                    end else end;
                end
            end

            COUNTING: begin
                clk_counter <= clk_counter + 1;
                if (clk_counter == delay[3:0] + 1) begin
                    o_completed <= 1'b1;
                    delay <= 0;
                    state <= DONE;
                end else begin
                    o_processing <= ~o_processing;
                    o_time_left <= o_time_left - 1;
                end
            end

            DONE: begin
                if (i_ack) begin
                    state <= IDLE;
                    o_completed <= 1'b0;
                end
            end
        endcase
    end

endmodule
