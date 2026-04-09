module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/signed_sequential_booth_multiplier.fst");
    $dumpvars(0, signed_sequential_booth_multiplier);
end
endmodule
