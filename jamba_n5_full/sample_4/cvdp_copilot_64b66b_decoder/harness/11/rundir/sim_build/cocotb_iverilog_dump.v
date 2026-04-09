module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/decoder_64b66b.fst");
    $dumpvars(0, decoder_64b66b);
end
endmodule
