module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/custom_byte_enable_ram.fst");
    $dumpvars(0, custom_byte_enable_ram);
end
endmodule
