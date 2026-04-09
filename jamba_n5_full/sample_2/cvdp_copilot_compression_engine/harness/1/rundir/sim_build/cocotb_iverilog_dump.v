module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/compression_engine.fst");
    $dumpvars(0, compression_engine);
end
endmodule
