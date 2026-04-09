module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/binary_to_bcd.fst");
    $dumpvars(0, binary_to_bcd);
end
endmodule
