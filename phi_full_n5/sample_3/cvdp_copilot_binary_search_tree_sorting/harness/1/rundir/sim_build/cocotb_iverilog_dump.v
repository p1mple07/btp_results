module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/binary_search_tree_sort.fst");
    $dumpvars(0, binary_search_tree_sort);
end
endmodule
