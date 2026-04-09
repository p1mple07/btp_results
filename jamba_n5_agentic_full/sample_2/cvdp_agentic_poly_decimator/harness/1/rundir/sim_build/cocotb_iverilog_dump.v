module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/poly_decimator.fst");
    $dumpvars(0, poly_decimator);
end
endmodule
