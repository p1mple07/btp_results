module low_power_channel (
    input logic clk,
    input logic reset,
    input logic if_wakeup_i,
    input logic wr_valid_i,
    input logic rd_valid_i,
    input logic wr_payload_i,
    input logic wr_done_i,
    input logic qreqn_i,
    input logic qacceptn_i,
    input logic qactive_i,
    output logic wr_flush_o,
    output logic rd_payload_o,
    output logic qacceptn_o,
    output logic qactive_o
);

    // Instantiate the FIFO controller
    sync_fifo #(.DEPTH(8), .DATA_W(8)) u_sync (
        .clk(clk),
        .reset(reset),
        .push_i(wr_valid_i),
        .pop_i(rd_valid_i),
        .full_o(wr_flush_o),
        .empty_o(? /* maybe unused? but we can ignore?*/ ),
        .qreqn_i(qreqn_i),
        .qacceptn_i(qacceptn_i),
        .qactive_o(qactive_o)
    );

    // Instantiate the control unit
    low_power_ctrl #(.CLK(clk), .RESET(reset)) u_ctrl (
        .clk(clk),
        .reset(reset),
        .if_wakeup_i(if_wakeup_i),
        .wr_valid_i(wr_valid_i),
        .rd_valid_i(rd_valid_i),
        .wr_payload_i(wr_payload_i),
        .wr_done_i(wr_done_i),
        .rd_payload_o(rd_payload_o),
        .qreqn_i(qreqn_i),
        .qacceptn_i(qacceptn_i),
        .qactive_o(qactive_o)
    );

endmodule
