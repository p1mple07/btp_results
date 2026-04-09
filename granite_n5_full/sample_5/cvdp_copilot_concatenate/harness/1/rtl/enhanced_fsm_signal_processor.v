module enhanced_fsm_signal_processor #(
    parameter C_CLK_FREQ = 100e6 // 100MHz
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_enable,
    input wire i_clear,
    input wire i_ack,
    input wire i_fault,
    input wire [4:0] i_vector_1,
    input wire [4:0] i_vector_2,
    input wire [4:0] i_vector_3,
    input wire [4:0] i_vector_4,
    input wire [4:0] i_vector_5,
    input wire [4:0] i_vector_6,
    output reg o_ready,
    output reg o_error,
    output reg [1:0] o_fsm_status,
    output reg [7:0] o_vector_1,
    output reg [7:0] o_vector_2,
    output reg [7:0] o_vector_3,
    output reg [7:0] o_vector_4
);

    localparam C_CLK_PERIOD = 100e9 / C_CLK_FREQ; // Calculate clock period based on clock frequency

    enum {
        IDLE = 2'b00,
        PROCESS = 2'b01,
        READY = 2'b10,
        FAULT = 2'b11
    } fsm_state, next_fsm_state;

    reg [31:0] data_bus;
    reg [7:0] vector_1, vector_2, vector_3, vector_4;
    reg fault;

    always @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            fsm_state <= IDLE;
            data_bus <= 32'h0;
            vector_1 <= 8'h0;
            vector_2 <= 8'h0;
            vector_3 <= 8'h0;
            vector_4 <= 8'h0;
            fault <= 1'b0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    if (i_enable) begin
                        fsm_state <= PROCESS;
                        data_bus <= {{8{i_vector_1[4]}}, i_vector_1[3:0], {{8{i_vector_2[4]}}, i_vector_2[3:0], {{8{i_vector_3[4]}}, i_vector_3[3:0], {{8{i_vector_4[4]}}, i_vector_4[3:0], {{8{i_vector_5[4]}}, i_vector_5[3:0], {{8{i_vector_6[4]}}, i_vector_6[3:0]}}}}};
                    end
                end
                PROCESS: begin
                    fsm_state <= READY;
                    data_bus <= {{8{i_vector_1[4]}}, i_vector_1[3:0], {{8{i_vector_2[4]}}, i_vector_2[3:0], {{8{i_vector_3[4]}}, i_vector_3[3:0], {{8{i_vector_4[4]}}, i_vector_4[3:0], {{8{i_vector_5[4]}}, i_vector_5[3:0], {{8{i_vector_6[4]}}, i_vector_6[3:0]}}}}};
                end
                READY: begin
                    o_ready <= 1'b1;
                    if (i_ack) begin
                        fsm_state <= IDLE;
                    end
                end
                FAULT: begin
                    o_error <= 1'b1;
                    if (i_clear &&!i_fault) begin
                        fsm_state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign o_fsm_status = fsm_state;
    assign o_vector_1 = vector_1;
    assign o_vector_2 = vector_2;
    assign o_vector_3 = vector_3;
    assign o_vector_4 = vector_4;

endmodule