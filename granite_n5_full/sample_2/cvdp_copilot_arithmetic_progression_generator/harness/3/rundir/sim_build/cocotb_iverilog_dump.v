module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/arithmetic_progression_generator.fst");
    $dumpvars(0, arithmetic_progression_generator);
end
endmodule
