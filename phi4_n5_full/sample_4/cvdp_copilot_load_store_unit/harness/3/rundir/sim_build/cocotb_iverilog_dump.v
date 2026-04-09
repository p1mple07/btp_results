module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/load_store_unit.fst");
    $dumpvars(0, load_store_unit);
end
endmodule
