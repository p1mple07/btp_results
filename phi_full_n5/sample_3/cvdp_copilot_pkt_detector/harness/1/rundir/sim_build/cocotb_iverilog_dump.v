module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pkt_detector.fst");
    $dumpvars(0, pkt_detector);
end
endmodule
