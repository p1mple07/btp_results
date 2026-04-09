module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/serial_in_parallel_out_8bit.fst");
    $dumpvars(0, serial_in_parallel_out_8bit);
end
endmodule
