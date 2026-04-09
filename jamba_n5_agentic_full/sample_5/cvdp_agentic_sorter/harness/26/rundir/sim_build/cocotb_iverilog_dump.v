module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/order_matching_engine.fst");
    $dumpvars(0, order_matching_engine);
end
endmodule
