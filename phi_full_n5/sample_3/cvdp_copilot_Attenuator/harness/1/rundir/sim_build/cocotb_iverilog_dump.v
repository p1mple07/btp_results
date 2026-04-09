module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/Attenuator.fst");
    $dumpvars(0, Attenuator);
end
endmodule
