module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fifo_buffer.fst");
    $dumpvars(0, fifo_buffer);
end
endmodule
