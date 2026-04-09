module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/aes_encrypt.fst");
    $dumpvars(0, aes_encrypt);
end
endmodule
