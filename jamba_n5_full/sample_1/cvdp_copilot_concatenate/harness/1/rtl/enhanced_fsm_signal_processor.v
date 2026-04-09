module enhanced_fsm_signal_processor (
    input         i_clk,
    input         i_rst_n,
    input [1:0]   i_enable,
    input [1:0]   i_clear,
    input [1:0]   i_ack,
    input [1:0]   i_fault,
    input [4:0]   i_vector_1,
    input [4:0]   i_vector_2,
    input [4:0]   i_vector_3,
    input [4:0]   i_vector_4,
    input [4:0]   i_vector_5,
    input [4:0]   i_vector_6,
    output reg    o_ready,
    output reg    o_error,
    output [1:0]  o_fsm_status,
    output [7:0]  o_vector_1,
    output [7:0]  o_vector_2,
    output [7:0]  o_vector_3,
    output [7:0]  o_vector_4
);

    localparam NUM_BITS = 32;
    localparam BUS_WIDTH = 30;
    localparam MASK = 31'hFFFF;

    reg [1:0] state;
    reg [7:0] fsm_output;
    reg [1:0] fsm_state;
    reg [1:0] next_state;
    reg [1:0] clear_next;
    reg [1:0] ack_next;
    reg [1:0] ready_next;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            state <= IDLE;
            o_ready <= 1'b0;
            o_error <= 1'b0;
            o_fsm_status <= 2'b00;
            o_vector_1 <= {31:0}[0:0];
            o_vector_2 <= {31:0}[0:0];
            o_vector_3 <= {31:0}[0:0];
            o_vector_4 <= {31:0}[0:0];
        end
        else begin
            case(state)
                1'b0: begin
                    if (i_enable) begin
                        next_state <= PROCESS;
                    end else
                        next_state <= IDLE;
                    end
                end
                1'b1: begin
                    if (i_enable && !i_clear) next_state <= READY;
                    else if (i_clear) next_state <= IDLE;
                    else if (i_fault) next_state <= FAULT;
                    else next_state <= PROCESS;
                    end
                end
                1'b2: begin
                    if (i_ack) next_state <= IDLE;
                    else next_state <= READY;
                    end
                1'b3: begin
                    next_state <= IDLE;
                    end
            endcase
        end
    end

    assign o_ready = state == 1'b1;
    assign o_error = state == 1'b2;
    assign o_fsm_status = state;
    assign o_vector_1 = {bus[27:28], bus[23:20], bus[15:12], bus[7:4], bus[1:0]};
    assign o_vector_2 = {bus[27:28], bus[23:20], bus[15:12], bus[7:4], bus[1:0]};
    assign o_vector_3 = {bus[27:28], bus[23:20], bus[15:12], bus[7:4], bus[1:0]};
    assign o_vector_4 = {bus[27:28], bus[23:20], bus[15:12], bus[7:4], bus[1:0]};

endmodule
