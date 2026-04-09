module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/rc5_enc_16bit.fst");
    $dumpvars(0, rc5_enc_16bit);
end
endmodule
