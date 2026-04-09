module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/decoder_8b10b.fst");
    $dumpvars(0, decoder_8b10b);
end
endmodule
