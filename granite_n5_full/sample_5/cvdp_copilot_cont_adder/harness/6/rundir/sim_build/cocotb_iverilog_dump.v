module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/continuous_adder.fst");
    $dumpvars(0, continuous_adder);
end
endmodule
