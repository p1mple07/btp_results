module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pipeline_mac.fst");
    $dumpvars(0, pipeline_mac);
end
endmodule
