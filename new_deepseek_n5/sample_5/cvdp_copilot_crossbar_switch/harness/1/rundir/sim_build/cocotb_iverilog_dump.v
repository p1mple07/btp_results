module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/crossbar_switch.fst");
    $dumpvars(0, crossbar_switch);
end
endmodule
