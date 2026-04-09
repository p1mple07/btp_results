module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/des3_dec.fst");
    $dumpvars(0, des3_dec);
end
endmodule
