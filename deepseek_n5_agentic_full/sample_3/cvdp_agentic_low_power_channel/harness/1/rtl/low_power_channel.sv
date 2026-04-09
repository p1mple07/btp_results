module low_power_channel(
    // Clock and reset
    input  clock,
    input  reset,
    
    // Control signals
    input  logic        if_wakeup_i,
    input  logic        wr_valid_i,
    input  logic [7:0] wr_payload_i,
    input  logic        wr_flush_i,
    output logic        qreqn_i,
    output logic        qacceptn_i,
    output logic        qactive_i,
    
    // FIFO interface
    input  logic       fifo_push_i,
    input  logic [7:0]fifo_push_data_i,
    input  logic       fifo_pop_i,
    output logic [7:0] fifo_pop_data_o,
    output logic        fifo_full_o,
    output logic        fifo_empty_o
    
);

// Instantiate control unit
low_power_ctrl#( .clk(clock), .reset(reset), 
                 .if_wakeup_i(if_wakeup_i),
                 .wr_valid_i(wr_valid_i),
                 .wr_payload_i(wr_payload_i),
                 .wr_flush_i(wr_flush_i),
                 .qreqn_i(qreqn_i),
                 .qacceptn_i(qacceptn_i),
                 .qactive_i(qactive_i),
                 .fifo_push_i(fifo_push_i),
                 .fifo_push_data_i(fifo_push_data_i),
                 .fifo_pop_i(fifo_pop_i),
                 .fifo_full_o(fifo_full_o),
                 .fifo_empty_o(fifo_empty_o) ) ctrl;

// Connect FIFO pointers
wire ctrl.fifo_n[0:DEPTH-1] == fifo_mem[ctrl.fifo_push_i:ctrl.fifo_push_i + DEPTH -1];

// Connect FIFO pointer increment/decrement
wire ( (ctrl.fifo_push_i + 1) & ~(ctrl.fifo_push_i >> POWER_H) )
       == ~( (ctrl.fifo_push_i >> (POWER_H+1)) | ( (ctrl.fifo_push_i + 1) & ( (1<<POWER_H)-1 )) );
wire ( (ctrl.fifo_push_i - 1) & ~(ctrl.fifo_push_i >> POWER_H) )
       == ~( (ctrl.fifo_push_i >> (POWER_H+1)) | ( (ctrl.fifo_push_i - 1) & ( (1<<POWER_H)-1 )) );

// FIFO full/empty check
always_comb
    assign fifo_full_o = ( ( (ctrl.fifo_push_i + wr_valid_i ? ctrl.fifo_push_i : fifo_mem[ctrl.fifo_push_i + 1] : 0) ) 
                        & ( ( (ctrl.fifo_push_i - wr_valid_i ? ctrl.fifo_push_i : fifo_mem[ctrl.fifo_push_i - 1] : 0) ) 
                        == fifo_mem[ctrl.fifo_push_i + 1] 
                        & fifo_mem[ctrl.fifo_push_i - 1] );

// Always blocks for FIFO initialization
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        fifo_push_i <= 0;
    else
        fifo_push_i <= next_fio_push;
        fifo_pop_i <= 0;
end

// Q-channel logic
always_comb
    assign next_qactive = (state_q == ST_Q_REQUEST) ? (ST_Q_REQUEST_next_state(state_q) & (!qacceptn_i))
                                         : (ST_Q_REQUEST Stamina ? !next_qactive : !(qacceptn_i & qactive_n));

assign next_qaccept  = (wr_done_i & wr_valid_i & ~qactive_i);

// FIFO push/pull based on control signals
always_comb
    assign next_fio_push  = ((qactive_n & ~qacceptn_i) ? ST_Q_REQUEST Stamina : 0) 
                           | ((~qactive_n & qacceptn_i) ? ST_Q_STOPP Stamina : 0);

always_comb
    assign next_fio_pop  = ((qactive_n & qacceptn_i) ? ST_Q_STOPP Stamina : 0) 
                           | ((~qactive_n & ~qacceptn_i) ? ST_Q_EXIT Stamina : 0);

always_comb
    assign next_fio_ptr = (ptr_q == ST_Q_RUN) ? next_rd_ptr : ptr_q;

// Edge case handling
always_comb
    assign next_qactive_o = qactive_n | (state_q == ST_Q_REQUEST & qacceptn_i);

endmodule