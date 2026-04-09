module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/nmea_decoder.fst");
    $dumpvars(0, nmea_decoder);
end
endmodule
