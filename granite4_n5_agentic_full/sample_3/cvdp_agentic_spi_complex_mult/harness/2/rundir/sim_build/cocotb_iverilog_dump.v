module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/spi_complex_mult.fst");
    $dumpvars(0, spi_complex_mult);
end
endmodule
