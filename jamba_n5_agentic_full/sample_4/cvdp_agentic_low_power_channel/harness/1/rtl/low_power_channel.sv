module low_power_channel (
    input  logic        clk,
    input  logic        reset,

    // FIFO interface
    input  logic        if_wakeup_i,
    input  logic        wr_valid_i,
    input  logic [7:0] wr_payload_i,

    // FIFO outputs
    output logic        qreqn_i,
    output logic        qacceptn_o,
    output logic        qactive_o,

    // FIFO data
    output logic [7:0] pop_data_o,
    output logic        full_o,
    output logic        empty_o
);

    // Instantiate the FIFO
    sync_fifo #(.DEPTH(8), .DATA_W(8)) u_sync_fifo (
        .clk(clk),
        .reset(reset),
        .push_i(if_wakeup_i),
        .pop_i(wr_valid_i),
        .full_o(full_o),
        .empty_o(empty_o),
        .qreqn_i(qreqn_i),
        .qacceptn_o(qacceptn_o),
        .qactive_o(qactive_o)
    );

    // Instantiate the control unit
    low_power_ctrl #(.CLK(clk)) u_ctrl (
        .clk(clk),
        .rst(reset),
        .if_wakeup_i(if_wakeup_i),
        .wr_valid_i(wr_valid_i),
        .wr_payload_i(wr_payload_i),
        .wr_done_i(wr_done_i),
        .rd_valid_i(rd_valid_i),
        .rd_payload_o(rd_payload_o),
        .qreqn_i(qreqn_i),
        .qacceptn_o(qacceptn_o),
        .qactive_o(qactive_o)
    );

endmodule
