module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sync_pos_neg_edge_detector.fst");
    $dumpvars(0, sync_pos_neg_edge_detector);
end
endmodule
