module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/galois_encryption.fst");
    $dumpvars(0, galois_encryption);
end
endmodule
