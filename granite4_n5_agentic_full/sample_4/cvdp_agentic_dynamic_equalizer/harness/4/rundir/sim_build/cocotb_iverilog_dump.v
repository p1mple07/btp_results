module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/dynamic_equalizer.fst");
    $dumpvars(0, dynamic_equalizer);
end
endmodule
