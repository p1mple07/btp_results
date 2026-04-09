module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/glitch_free_mux.fst");
    $dumpvars(0, glitch_free_mux);
end
endmodule
