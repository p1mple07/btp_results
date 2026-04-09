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
    output [2:0] o_fsm_status
);

    // State encoding
    localparam IDLE = 3'b000,
            PROCESS = 3'b001,
            READY = 3'b010,
            FAULT = 3'b011;

    // State register
    reg [2:0] state_reg = IDLE;

    // FSM control logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            state_reg <= IDLE;
            o_ready <= 0;
            o_error <= 0;
            o_fsm_status <= IDLE;
        end else begin
            case (state_reg)
                IDLE: begin
                    if (!i_enable) state_reg <= IDLE;
                    if (i_fault) state_reg <= FAULT;
                end
                PROCESS: begin
                    if (i_fault) state_reg <= FAULT;
                    else begin
                        o_vector_1 <= i_vector_1;
                        o_vector_2 <= i_vector_2;
                        o_vector_3 <= i_vector_3;
                        o_vector_4 <= i_vector_4;
                        o_ready <= 1;
                        state_reg <= READY;
                    end
                end
                READY: begin
                    if (i_ack) state_reg <= IDLE;
                    if (i_fault) state_reg <= FAULT;
                end
                FAULT: begin
                    o_error <= 1;
                    state_reg <= IDLE;
                end
            endcase
        end
    end

    // Output logic
    always @(state_reg, i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6) begin
        case (state_reg)
            IDLE: begin
                o_vector_1 <= 8'h00;
                o_vector_2 <= 8'h00;
                o_vector_3 <= 8'h00;
                o_vector_4 <= 8'h00;
            end
            PROCESS: begin
                o_vector_1 <= {i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 1'b1};
                o_vector_2 <= {i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 1'b1};
                o_vector_3 <= {i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 1'b1};
                o_vector_4 <= {i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 1'b1};
            end
            READY: begin
                o_ready <= 1;
            end
            FAULT: begin
                o_error <= 1;
            end
        endcase
    end

endmodule
