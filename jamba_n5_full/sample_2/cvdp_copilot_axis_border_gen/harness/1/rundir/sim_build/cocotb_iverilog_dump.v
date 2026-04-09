module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axis_image_border_gen.fst");
    $dumpvars(0, axis_image_border_gen);
end
endmodule
