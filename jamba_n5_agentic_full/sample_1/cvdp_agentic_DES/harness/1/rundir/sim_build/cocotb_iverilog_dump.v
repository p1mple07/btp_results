module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/des_enc.fst");
    $dumpvars(0, des_enc);
end
endmodule
