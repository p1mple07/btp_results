module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/signed_unsigned_comparator.fst");
    $dumpvars(0, signed_unsigned_comparator);
end
endmodule
