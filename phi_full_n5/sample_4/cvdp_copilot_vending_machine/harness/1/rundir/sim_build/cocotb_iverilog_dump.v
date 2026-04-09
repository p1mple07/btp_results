module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/vending_machine.fst");
    $dumpvars(0, vending_machine);
end
endmodule
