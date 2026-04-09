module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/queue.fst");
    $dumpvars(0, queue);
end
endmodule
