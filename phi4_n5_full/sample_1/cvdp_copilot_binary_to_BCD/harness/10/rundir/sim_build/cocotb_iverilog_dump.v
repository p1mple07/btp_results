module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/binary_bcd_converter_twoway.fst");
    $dumpvars(0, binary_bcd_converter_twoway);
end
endmodule
