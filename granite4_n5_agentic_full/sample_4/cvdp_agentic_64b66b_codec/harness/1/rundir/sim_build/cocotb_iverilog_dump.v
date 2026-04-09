module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/top_64b66b_codec.fst");
    $dumpvars(0, top_64b66b_codec);
end
endmodule
