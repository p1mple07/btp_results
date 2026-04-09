module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/coffee_machine.fst");
    $dumpvars(0, coffee_machine);
end
endmodule
