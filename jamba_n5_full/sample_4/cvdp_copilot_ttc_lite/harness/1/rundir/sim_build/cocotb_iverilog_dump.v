module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ttc_counter_lite.fst");
    $dumpvars(0, ttc_counter_lite);
end
endmodule
