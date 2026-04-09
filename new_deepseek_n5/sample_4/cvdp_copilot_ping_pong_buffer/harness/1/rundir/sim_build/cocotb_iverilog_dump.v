module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ping_pong_buffer.fst");
    $dumpvars(0, ping_pong_buffer);
end
endmodule
