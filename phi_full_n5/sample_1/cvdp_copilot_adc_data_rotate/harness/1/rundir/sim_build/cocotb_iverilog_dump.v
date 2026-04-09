module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/adc_data_rotate.fst");
    $dumpvars(0, adc_data_rotate);
end
endmodule
