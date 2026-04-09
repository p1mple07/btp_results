module enhanced_fsm_signal_processor(
    input i_clk,
    input i_rst_n,
    input i_enable,
    input i_clear,
    input i_ack,
    input i_fault,
    input [5:0] i_vector_1,
    input [5:0] i_vector_2,
    input [5:0] i_vector_3,
    input [5:0] i_vector_4,
    input [5:0] i_vector_5,
    input [5:0] i_vector_6,
    output reg o_ready,
    output reg o_error,
    output reg [2:0] o_fsm_status,
    output [7:0] o_vector_1,
    output [7:0] o_vector_2,
    output [7:0] o_vector_3,
    output [7:0] o_vector_4
);

    // State register
    reg [2:0] current_state, next_state;

    // Reset condition
    always @ (posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            current_state <= 3'b000;
            o_ready <= 0;
            o_error <= 0;
            o_fsm_status <= 3'b000;
            o_vector_1 <= 8'b0;
            o_vector_2 <= 8'b0;
            o_vector_3 <= 8'b0;
            o_vector_4 <= 8'b0;
        end else begin
            if (i_enable) begin
                current_state <= 3'b000;
            end
        end
    end

    // State transition logic
    always @ (posedge i_clk) begin
        case (current_state)
            3'b000: begin
                if (i_fault) begin
                    next_state <= 3'b111;
                end else begin
                    next_state <= 3'b001;
                end
            end
            3'b001: begin
                if (!i_fault) begin
                    next_state <= 3'b010;
                end else begin
                    next_state <= 3'b111;
                end
            end
            3'b010: begin
                if (!i_ack) begin
                    next_state <= 3'b000;
                end
            end
            3'b111: begin
                next_state <= 3'b000;
            end
        endcase
        current_state <= next_state;
    end

    // Process state logic
    always @ (current_state == 3'b001) begin
        if (!i_fault) begin
            o_vector_1 <= i_vector_1;
            o_vector_2 <= i_vector_2;
            o_vector_3 <= i_vector_3;
            o_vector_4 <= i_vector_4;
            o_fsm_status <= 3'b010;
        end
    end

    // Ready state logic
    always @ (current_state == 3'b010) begin
        if (!i_ack) begin
            o_fsm_status <= 3'b000;
        end else begin
            o_fsm_status <= 3'b010;
        end
        o_ready <= 1;
    end

    // Fault state logic
    always @ (current_state == 3'b111) begin
        if (i_clear && !i_fault) begin
            o_fsm_status <= 3'b000;
        end else begin
            o_error <= 1;
        end
    end

endmodule
