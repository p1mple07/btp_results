module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sync_muller_c_element.fst");
    $dumpvars(0, sync_muller_c_element);
end
endmodule
