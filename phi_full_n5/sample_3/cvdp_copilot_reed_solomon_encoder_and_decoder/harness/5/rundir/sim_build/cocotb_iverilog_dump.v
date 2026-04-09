module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/reed_solomon_encoder.fst");
    $dumpvars(0, reed_solomon_encoder);
end
endmodule
