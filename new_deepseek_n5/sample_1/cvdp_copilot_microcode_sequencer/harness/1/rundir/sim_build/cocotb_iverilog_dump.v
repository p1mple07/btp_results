module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/microcode_sequencer.fst");
    $dumpvars(0, microcode_sequencer);
end
endmodule
