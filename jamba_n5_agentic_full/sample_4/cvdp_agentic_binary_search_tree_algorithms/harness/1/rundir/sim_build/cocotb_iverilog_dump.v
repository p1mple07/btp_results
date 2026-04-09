module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/delete_node_binary_search_tree.fst");
    $dumpvars(0, delete_node_binary_search_tree);
end
endmodule
