module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sync_serial_communication_tx_rx.fst");
    $dumpvars(0, sync_serial_communication_tx_rx);
end
endmodule
