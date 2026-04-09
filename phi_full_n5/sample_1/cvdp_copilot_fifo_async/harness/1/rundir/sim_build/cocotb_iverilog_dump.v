module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fifo_async.fst");
    $dumpvars(0, fifo_async);
end
endmodule
