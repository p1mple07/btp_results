module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/scrambler_descrambler.fst");
    $dumpvars(0, scrambler_descrambler);
end
endmodule
