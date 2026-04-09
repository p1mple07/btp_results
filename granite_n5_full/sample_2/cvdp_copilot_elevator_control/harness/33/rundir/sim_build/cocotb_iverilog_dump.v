module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/elevator_control_system.fst");
    $dumpvars(0, elevator_control_system);
end
endmodule
