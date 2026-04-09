module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/low_power_channel.fst");
    $dumpvars(0, low_power_channel);
end
endmodule
