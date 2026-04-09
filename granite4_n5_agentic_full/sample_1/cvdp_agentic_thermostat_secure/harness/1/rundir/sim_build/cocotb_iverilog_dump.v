module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/thermostat_secure_top.fst");
    $dumpvars(0, thermostat_secure_top);
end
endmodule
