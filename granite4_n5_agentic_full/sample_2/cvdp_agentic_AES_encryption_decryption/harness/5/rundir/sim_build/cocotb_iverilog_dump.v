module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/aes128_decrypt.fst");
    $dumpvars(0, aes128_decrypt);
end
endmodule
