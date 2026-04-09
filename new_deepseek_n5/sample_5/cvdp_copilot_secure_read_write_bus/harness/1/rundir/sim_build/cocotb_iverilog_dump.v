module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/secure_read_write_bus_interface.fst");
    $dumpvars(0, secure_read_write_bus_interface);
end
endmodule
