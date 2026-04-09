module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/moving_average.fst");
    $dumpvars(0, moving_average);
end
endmodule
