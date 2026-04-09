module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/SetBitStreamCalculator.fst");
    $dumpvars(0, SetBitStreamCalculator);
end
endmodule
