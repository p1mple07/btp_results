module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pipelined_modified_booth_multiplier.fst");
    $dumpvars(0, pipelined_modified_booth_multiplier);
end
endmodule
