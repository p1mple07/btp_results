module enhanced_fsm_signal_processor(
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
    output wire [7:0] o_vector_1,
    output wire [7:0] o_vector_2,
    output wire [7:0] o_vector_3,
    output wire [7:0] o_vector_4
);

// Define FSM states
enum logic [1:0] {IDLE, PROCESS, READY, FAULT} fsm_state, next_fsm_state;

always @(posedge i_clk or posedge i_rst_n) begin
    if (!i_rst_n) begin
        // Reset FSM and outputs
        fsm_state <= IDLE;
        o_ready <= 1'b0;
        o_error <= 1'b0;
        o_fsm_status <= 2'b00;
        o_vector_1 <= 8'b0;
        o_vector_2 <= 8'b0;
        o_vector_3 <= 8'b0;
        o_vector_4 <= 8'b0;
    end else begin
        // Update FSM based on inputs
        case (fsm_state)
            IDLE: begin
                if (i_enable) begin
                    fsm_state <= PROCESS;
                end
            end
            PROCESS: begin
                // Concatenate input vectors and append additional bits
                logic [29:0] bus;
                bus = {i_vector_6[4:0], i_vector_5[4:0], i_vector_4[4:0], i_vector_3[4:0], i_vector_2[4:0], i_vector_1[4:0]};
                bus[29] = 1'b0;
                bus[30] = 1'b0;
                
                // Split concatenated bus into individual output vectors
                o_vector_1 <= bus[23:16];
                o_vector_2 <= bus[15:8];
                o_vector_3 <= bus[7:0];
                o_vector_4 <= bus[31:24];
                
                // Transition to READY state once all input vectors are processed
                if (i_ack) begin
                    fsm_state <= READY;
                end
            end
            READY: begin
                // Assert o_ready signal
                o_ready <= 1'b1;
                fsm_state <= IDLE;
            end
            FAULT: begin
                // Handle fault condition and reset FSM to IDLE
                if (i_clear &&!i_fault) begin
                    fsm_state <= IDLE;
                    o_error <= 1'b0;
                end
            end
        endcase
        
        // Update output signals based on FSM state
        case (fsm_state)
            IDLE: begin
                o_fsm_status <= 2'b00;
            end
            PROCESS: begin
                o_fsm_status <= 2'b01;
            end
            READY: begin
                o_fsm_status <= 2'b10;
            end
            FAULT: begin
                o_fsm_status <= 2'b11;
            end
        endcase
    end
end

endmodule