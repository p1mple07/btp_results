module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/wishbone_to_ahb_bridge.fst");
    $dumpvars(0, wishbone_to_ahb_bridge);
end
endmodule
