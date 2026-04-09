module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/factorial.fst");
    $dumpvars(0, factorial);
end
endmodule
