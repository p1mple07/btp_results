module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/barrel_shifter_8bit.fst");
    $dumpvars(0, barrel_shifter_8bit);
end
endmodule
