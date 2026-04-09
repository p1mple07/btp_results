module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/crypto_accelerator.fst");
    $dumpvars(0, crypto_accelerator);
end
endmodule
