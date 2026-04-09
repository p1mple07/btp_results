module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/door_lock.fst");
    $dumpvars(0, door_lock);
end
endmodule
