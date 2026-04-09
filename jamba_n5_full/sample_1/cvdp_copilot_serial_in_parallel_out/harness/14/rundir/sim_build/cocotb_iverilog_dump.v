module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sipo_top.fst");
    $dumpvars(0, sipo_top);
end
endmodule
