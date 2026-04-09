module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/copilot_rs_232.fst");
    $dumpvars(0, copilot_rs_232);
end
endmodule
