module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_copilot_decode_firstbit.fst");
    $dumpvars(0, cvdp_copilot_decode_firstbit);
end
endmodule
