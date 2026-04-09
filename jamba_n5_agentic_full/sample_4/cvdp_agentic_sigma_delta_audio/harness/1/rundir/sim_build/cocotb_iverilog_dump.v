module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sigma_delta_audio.fst");
    $dumpvars(0, sigma_delta_audio);
end
endmodule
