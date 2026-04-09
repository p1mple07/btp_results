module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/spi_fsm.fst");
    $dumpvars(0, spi_fsm);
end
endmodule
