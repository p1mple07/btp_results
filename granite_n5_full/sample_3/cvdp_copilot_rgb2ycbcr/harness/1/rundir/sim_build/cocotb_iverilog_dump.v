module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axis_rgb2ycbcr.fst");
    $dumpvars(0, axis_rgb2ycbcr);
end
endmodule
