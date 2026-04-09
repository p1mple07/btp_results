module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/line_buffer.fst");
    $dumpvars(0, line_buffer);
end
endmodule
