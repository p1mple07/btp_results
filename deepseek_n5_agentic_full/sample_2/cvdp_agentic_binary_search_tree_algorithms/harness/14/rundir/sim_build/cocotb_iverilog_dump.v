module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bst_operations.fst");
    $dumpvars(0, bst_operations);
end
endmodule
