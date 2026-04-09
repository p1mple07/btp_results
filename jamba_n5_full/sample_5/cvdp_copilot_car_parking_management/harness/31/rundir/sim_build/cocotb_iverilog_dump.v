module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/car_parking_system.fst");
    $dumpvars(0, car_parking_system);
end
endmodule
