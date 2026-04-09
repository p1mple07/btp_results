rtl/hebb_gates.sv
--------------------------------------------------
module hebbian_rule (
    input  logic         clk,    // Clock signal (posedge)
    input  logic         rst,    // Asynchronous active-low reset
    input  logic         start,  // Start signal (active HIGH)
    input  signed [3:0]  a,      // 4-bit signed input (only -1 and 1 valid)
    input  signed [3:0]  b,      // 4-bit signed input (only -1 and 1 valid)
    input  [1:0]         gate_select, // 2-bit gate selector
    output reg signed [3:0] w1,   // Trained weight for input a
    output reg signed [4:0] w2,   // Trained weight for input b
    output reg signed [3:0] bias, // Trained bias
    output reg [3:0]      present_state, // Current FSM state (Moore)
    output reg [3:0]      next_state     // Next FSM state (Moore)
);

    // FSM state encoding (11 states total)
    localparam STATE_RESET         = 4'd0;
    localparam STATE_CAPTURE       = 4'd1;
    localparam STATE_ASSIGN_AND    = 4'd2;
    localparam STATE_ASSIGN_OR     = 4'd3;
    localparam STATE_ASSIGN_NAND   = 4'd4;
    localparam STATE_ASSIGN_NOR    = 4'd5;
    localparam STATE_ASSIGN_DONE   = 4'd6;
    localparam STATE_COMPUTE_DELTAS= 4'd7;
    localparam STATE_UPDATE        = 4'd8;
    localparam STATE_LOOP          = 4'd9;
    localparam STATE_DONE          = 4'd10;

    // Internal registers
    reg [3:0] state, next_state_reg;
    reg [3:0] x1, x2;          // Captured inputs
    reg [3:0] target;          // Computed target value
    reg [3:0] delta_w1, delta_w2, delta_b; // Weight/bias deltas
    reg [1:0] iter_count;      // 2-bit iteration counter (for 4 training iterations)

    // Next state logic (combinational)
    always_comb begin
        case (state)
            STATE_RESET:
                next_state_reg = (start) ? STATE_CAPTURE : STATE_RESET;
            STATE_CAPTURE: begin
                case (gate_select)
                    2'b00: next_state_reg = STATE_ASSIGN_AND;
                    2'b01: next_state_reg = STATE_ASSIGN_OR;
                    2'b10: next_state_reg = STATE_ASSIGN_NAND;
                    2'b11: next_state_reg = STATE_ASSIGN_NOR;
                    default: next_state_reg = STATE_ASSIGN_DONE;
                endcase
            end
            STATE_ASSIGN_AND:
                next_state_reg = STATE_ASSIGN_DONE;
            STATE_ASSIGN_OR:
                next_state_reg = STATE_ASSIGN_DONE;
            STATE_ASSIGN_NAND:
                next_state_reg = STATE_ASSIGN_DONE;
            STATE_ASSIGN_NOR:
                next_state_reg = STATE_ASSIGN_DONE;
            STATE_ASSIGN_DONE:
                next_state_reg = STATE_COMPUTE_DELTAS;
            STATE_COMPUTE_DELTAS:
                next_state_reg = STATE_UPDATE;
            STATE_UPDATE:
                next_state_reg = STATE_LOOP;
            STATE_LOOP: begin
                if (iter_count == 2'd3)
                    next_state_reg = STATE_DONE;
                else
                    next_state_reg = STATE_CAPTURE;
            end
            STATE_DONE:
                next_state_reg = STATE_DONE;
            default:
                next_state_reg = STATE_RESET;
        endcase
    end

    // Sequential logic: state update and register updates
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state         <= STATE_RESET;
            w1            <= 4'd0;
            w2            <= 4'd0;
            bias          <= 4'd0;
            x1            <= 4'd0;
            x2            <= 4'd0;
            target        <= 4'd0;
            delta_w1      <= 4'd0;
            delta_w2      <= 4'd0;
            delta_b       <= 4'd0;
            iter_count    <= 2'd0;