module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ethernet_mii_tx.fst");
    $dumpvars(0, ethernet_mii_tx);
end
endmodule
