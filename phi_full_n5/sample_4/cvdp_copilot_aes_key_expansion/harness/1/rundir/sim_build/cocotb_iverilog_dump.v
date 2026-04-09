module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/key_expansion_128aes.fst");
    $dumpvars(0, key_expansion_128aes);
end
endmodule
