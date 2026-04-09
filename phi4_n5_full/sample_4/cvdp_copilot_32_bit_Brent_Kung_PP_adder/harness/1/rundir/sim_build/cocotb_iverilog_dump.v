module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/brent_kung_adder.fst");
    $dumpvars(0, brent_kung_adder);
end
endmodule
