module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/binary_multiplier.fst");
    $dumpvars(0, binary_multiplier);
end
endmodule
