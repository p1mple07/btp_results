module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/conv3x3.fst");
    $dumpvars(0, conv3x3);
end
endmodule
