module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/top_manchester.fst");
    $dumpvars(0, top_manchester);
end
endmodule
