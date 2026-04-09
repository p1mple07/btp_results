module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cascaded_adder.fst");
    $dumpvars(0, cascaded_adder);
end
endmodule
