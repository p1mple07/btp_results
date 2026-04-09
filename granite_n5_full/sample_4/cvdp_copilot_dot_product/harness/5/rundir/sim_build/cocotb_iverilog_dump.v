module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/dot_product.fst");
    $dumpvars(0, dot_product);
end
endmodule
