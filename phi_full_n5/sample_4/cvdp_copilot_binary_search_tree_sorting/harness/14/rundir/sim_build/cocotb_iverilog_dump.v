module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/search_binary_search_tree.fst");
    $dumpvars(0, search_binary_search_tree);
end
endmodule
