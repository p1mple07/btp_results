module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/signed_comparator.fst");
    $dumpvars(0, signed_comparator);
end
endmodule
