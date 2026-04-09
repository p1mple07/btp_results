module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/morse_encoder.fst");
    $dumpvars(0, morse_encoder);
end
endmodule
