module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/multiplexer.fst");
    $dumpvars(0, multiplexer);
end
endmodule
