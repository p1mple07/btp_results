module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/precision_counter_axi.fst");
    $dumpvars(0, precision_counter_axi);
end
endmodule
