module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axis_border_gen_with_resize.fst");
    $dumpvars(0, axis_border_gen_with_resize);
end
endmodule
