module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/square_root_seq.fst");
    $dumpvars(0, square_root_seq);
end
endmodule
