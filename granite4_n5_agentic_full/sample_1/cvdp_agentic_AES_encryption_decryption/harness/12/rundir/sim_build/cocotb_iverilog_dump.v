module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/aes_decrypt.fst");
    $dumpvars(0, aes_decrypt);
end
endmodule
