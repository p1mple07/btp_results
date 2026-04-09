module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hdbn_top.fst");
    $dumpvars(0, hdbn_top);
end
endmodule
