module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/prim_max_find.fst");
    $dumpvars(0, prim_max_find);
end
endmodule
