// Module declaration
module control_fsm(
    // Inputs
    input wire [7:0] i_clk,
    input wire [1:0] i_rst_async_n,
    input wire i_enable,
    input wire i_subsampling,
    input wire i_iw,
    input wire i_calc_valid,
    input wire i_calc_fail,
    input wire i_wd,
    input wire i_vth,

    // Outputs
    output reg [7:0] o_start_calc,
    output reg [7:0] o_valid,
    output reg [7:0] o_subsampling,
    output reg [7:0] o_wd,
    output reg [7:0] o_vth);

// FSM state variable
reg fsm_state = 0;

// Variables
parameter NBW_WAIT = 32;
reg gen_counter_val = 0;
reg wait_counter_val = 0;

always @posedge i_clk begin
    // State transitions
    case(fsm_state)
        0: // PROC_CONTROL_CAPTURE_ST
            if(i_enable)
                fsm_state = 1;
        1: // PROC_DATA_CAPTURE_ST
            if(gen_counter_val == 0)
                fsm_state = 2;
            else
                fsm_state = 1;
        2: // PROC_CALC_START_ST
            gen_counter_val = 0;
            wait_counter_val = $signed(i_wait);
            fsm_state = 3;
        3: // PROC_CALC_ST
            if($clock && !i_enable)
                fsm_state = 4;
            else if($clock && i_enable)
                fsm_state = 3;
        4: // PROC_WAIT_ST
            if(wait_counter_val == 0 || !i_enable)
                fsm_state = 0;
    endcase
end

// General Purpose Counter
wire [7:0] gen_counter;

always @negedge i_rst_async_n + '@posedge i_clk begin
    gen_counter = $signed(NBW_WAIT);
end

// Timeout Counter
wire [7:0] wait_counter;

always @posedge i_clk begin
    wait_counter = $signed(i_wait);
    gen_counter = 0;
end

// Output Calculation
always begin
    o_start_calc = fsm_state == 3;
    
    // o_valid
    o_valid = (
        (fsm_state >= 1 && fsm_state <= 3) && 
        iEnable && 
        ($signed(gen_counter) > 0)) ||
        (fsm_state == 0 && iEnable && $signed(gen_counter));

    // o_subsampling
    o_subsampling = i_subsampling;

    // o_wd
    o_wd = i_wd;

    // o_vth
    o_vth = i_vth;
end