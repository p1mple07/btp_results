module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/one_hot_gen.fst");
    $dumpvars(0, one_hot_gen);
end
endmodule
