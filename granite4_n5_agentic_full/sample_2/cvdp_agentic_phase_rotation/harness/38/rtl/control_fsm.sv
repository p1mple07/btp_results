module control_fsm (
    // Inputs
    input logic clk,
    input logic rst_async_n,
    input logic i_enable,
    input logic i_valid,
    input logic i_calc_valid,
    input logic i_calc_fail,
    input logic [7:0] i_wait,
    // Outputs
    output logic o_start_calc,
    output logic o_valid,
    output logic o_subsampling
);

// Define the FSM states
typedef enum logic [1:0] {
    PROC_CONTROL_CAPTURE_ST = 2'b00,
    PROC_DATA_CAPTURE_ST = 2'b01,
    PROC_CALC_START_ST = 2'b10,
    PROC_CALC_ST = 2'b11,
    PROC_WAIT_ST = 2'b01
} proc_fsm_st;

// Define the FSM registers and variables
logic [7:0] r_counter;
logic [7:0] r_timeout_counter;
logic o_start_calc_q;
logic o_start_calc_d;
proc_fsm_st r_state, d_state;

// Implement the FSM logic
always_ff @(posedge clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
        r_state <= PROC_CONTROL_CAPTURE_ST;
        r_counter <= 8'h00;
        r_timeout_counter <= 8'h00;
        o_start_calc_q <= 1'b0;
        o_valid <= 1'b0;
        o_subsampling <= 1'b0;
    end else begin
        case (r_state)
            PROC_CONTROL_CAPTURE_ST: begin
                if (i_enable && i_valid) begin
                    r_state <= PROC_DATA_CAPTURE_ST;
                    r_counter <= 8'h00;
                end
            end
            PROC_DATA_CAPTURE_ST: begin
                if (!i_enable) begin
                    r_state <= PROC_CONTROL_CAPTURE_ST;
                    r_counter <= r_counter + 1;
                end
            end
            PROC_CALC_START_ST: begin
                if (i_calc_valid) begin
                    r_state <= PROC_CALC_ST;
                end
            end
            PROC_CALC_ST: begin
                if (!i_calc_valid &&!i_calc_fail) begin
                    r_state <= PROC_CONTROL_CAPTURE_ST;
                end
            end
            default: begin
                r_state <= PROC_CONTROL_CAPTURE_ST;
            end
        endcase
    end
end

// Implement the counter logic
always_comb begin
    unique case (r_state)
        PROC_CONTROL_CAPTURE_ST: begin
            r_timeout_counter <= 8'h00;
        end
        PROC_DATA_CAPTURE_ST: begin
            if (i_enable) begin
                r_counter <= i_valid? r_counter + 1 : r_counter;
            end
        end
        PROC_CALC_START_ST: begin
            if (i_calc_valid) begin
                r_counter <= i_valid? i_valid + 1 : r_counter;
                r_state <= PROC_CALC_ST;
            end
        end
        PROC_CALC_ST: begin
            if (i_calc_valid) begin
                r_state <= PROC_CONTROL_CAPTURE_ST;
            end
        end
        default: begin
            r_state <= PROC_CONTROL_CAPTURE_ST;
        end
    endcase
    
    always_comb begin
        case (r_state)
            PROC_CONTROL_CAPTURE_ST: begin
                o_start_calc <= 1'b1;
            end
            PROC_DATA_CAPTURE_ST: begin
                if (i_enable) begin
                    o_valid <= 1'b1;
                end
            end
            PROC_CALC_START_ST: begin
                o_start_calc <= 1'b1;
            end
            PROC_CALC_ST: begin
                o_valid <= 1'b1;
            end
            PROC_WAIT_ST: begin
                o_start_calc <= 1'b1;
            end
            default: begin
                o_start_calc <= 1'b0;
            end
    end

    function int i_width() const

int i_data(int) const {
    int i_data(int) const {
        int i_data(int) const {
            int i_valid.
            int i_valid(int) const {
                int total_height(int) const {
                    int height(int) const {
                        int total_height(int) const {
                            return 1;
                        }
                    }
                }
            PROC_WAIT_ST: {
                    int i_wait(int) const {
                        return r_counter(int) const {
                            int width(int) const {
                                int width(int) const {
                                    return 16.
}
    function int i_width() const {
        int i_width(int) const {
            int i_width = 16;
            return i_width;
        }
    }