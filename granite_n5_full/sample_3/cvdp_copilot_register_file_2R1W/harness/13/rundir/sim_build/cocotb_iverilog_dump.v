module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_copilot_register_file_2R1W.fst");
    $dumpvars(0, cvdp_copilot_register_file_2R1W);
end
endmodule
