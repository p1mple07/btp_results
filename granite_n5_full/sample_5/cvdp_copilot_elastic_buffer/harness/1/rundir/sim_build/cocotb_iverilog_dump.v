module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/elastic_buffer_pattern_matcher.fst");
    $dumpvars(0, elastic_buffer_pattern_matcher);
end
endmodule
