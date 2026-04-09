module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cdc_pulse_synchronizer.fst");
    $dumpvars(0, cdc_pulse_synchronizer);
end
endmodule
