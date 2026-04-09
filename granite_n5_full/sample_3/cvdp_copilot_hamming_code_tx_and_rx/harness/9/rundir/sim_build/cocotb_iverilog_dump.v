module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hamming_tx.fst");
    $dumpvars(0, hamming_tx);
end
endmodule
