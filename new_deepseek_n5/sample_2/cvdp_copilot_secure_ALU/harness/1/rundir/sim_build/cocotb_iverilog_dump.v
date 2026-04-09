module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/alu_seq.fst");
    $dumpvars(0, alu_seq);
end
endmodule
