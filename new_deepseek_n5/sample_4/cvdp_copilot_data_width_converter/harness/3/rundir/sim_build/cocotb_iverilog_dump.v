module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/data_width_converter.fst");
    $dumpvars(0, data_width_converter);
end
endmodule
