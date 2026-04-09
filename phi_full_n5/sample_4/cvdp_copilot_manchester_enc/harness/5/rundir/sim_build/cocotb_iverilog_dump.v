module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/manchester_encoder.fst");
    $dumpvars(0, manchester_encoder);
end
endmodule
