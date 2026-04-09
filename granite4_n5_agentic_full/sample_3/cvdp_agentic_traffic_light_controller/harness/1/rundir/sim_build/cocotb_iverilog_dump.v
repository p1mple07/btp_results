module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/traffic_light_controller_top.fst");
    $dumpvars(0, traffic_light_controller_top);
end
endmodule
