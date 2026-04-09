module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/des_dec.fst");
    $dumpvars(0, des_dec);
end
endmodule
