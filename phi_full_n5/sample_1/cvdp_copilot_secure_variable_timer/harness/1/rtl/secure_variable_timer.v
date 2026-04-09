
module secure_variable_timer (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_data_in,
    output reg [3:0] o_time_left,
    output reg o_processing,
    output reg o_completed,
    input wire i_ack
);

    // Internal registers
    reg [3:0] delay;
    reg [9:0] counter;
    reg [3:0] time_left_reg;
    reg [3:0] current_delay;
    reg [3:0] next_delay;
    reg [3:0] delay_detected;

    // State declaration
    typedef enum reg (
        idle,
        configure_delay,
        counting,
        done
    ) state_t;
    state_t current_state, next_state;

    // State transition logic
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            current_state <= idle;
            counter <= 0;
            time_left_reg <= 0;
            delay_detected <= 0;
        end else begin
            case (current_state)
                idle: begin
                    if (i_data_in === 4'b1101) begin
                        current_state <= configure_delay;
                        delay_detected <= 1;
                    end else begin
                        current_state <= idle;
                    end
                end
                configure_delay: begin
                    if (!delay_detected) begin
                        delay <= i_data_in;
                        next_delay <= delay;
                        current_state <= counting;
                    end else begin
                        current_state <= configure_delay;
                    end
                end
                counting: begin
                    if (counter >= (next_delay + 1) * 1000) begin
                        o_time_left <= time_left_reg;
                        o_processing <= 1;
                        o_completed <= 1;
                        next_state <= done;
                    end else begin
                        time_left_reg <= time_left_reg - 1;
                        counter <= counter + 1;
                        current_state <= counting;
                    end
                end
                done: begin
                    if (i_ack) begin
                        current_state <= idle;
                        time_left_reg <= 0;
                        counter <= 0;
                    end else begin
                        current_state <= done;
                    end
                end
            endcase
        end
    end

    // Counting logic
    always @(posedge i_clk) begin
        if (delay_detected) begin
            if (current_state == counting) begin
                counter <= counter + 1;
            end
        end
    end

endmodule

