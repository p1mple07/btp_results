module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/data_bus_controller.fst");
    $dumpvars(0, data_bus_controller);
end
endmodule
