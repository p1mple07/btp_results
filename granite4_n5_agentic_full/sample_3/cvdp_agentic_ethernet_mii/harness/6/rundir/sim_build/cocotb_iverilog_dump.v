module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ethernet_mac_tx.fst");
    $dumpvars(0, ethernet_mac_tx);
end
endmodule
