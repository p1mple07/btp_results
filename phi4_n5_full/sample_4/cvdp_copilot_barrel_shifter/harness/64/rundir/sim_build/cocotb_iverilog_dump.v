module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/barrel_shifter.fst");
    $dumpvars(0, barrel_shifter);
end
endmodule
