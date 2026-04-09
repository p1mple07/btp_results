module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/equalizer_top.fst");
    $dumpvars(0, equalizer_top);
end
endmodule
