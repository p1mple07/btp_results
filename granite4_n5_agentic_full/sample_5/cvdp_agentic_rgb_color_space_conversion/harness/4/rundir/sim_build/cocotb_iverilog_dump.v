module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/rgb_color_space_conversion.fst");
    $dumpvars(0, rgb_color_space_conversion);
end
endmodule
