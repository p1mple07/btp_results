module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/write_buffer_merge.fst");
    $dumpvars(0, write_buffer_merge);
end
endmodule
