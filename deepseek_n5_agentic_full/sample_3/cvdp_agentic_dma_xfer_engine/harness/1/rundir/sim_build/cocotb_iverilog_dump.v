module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/dma_xfer_engine.fst");
    $dumpvars(0, dma_xfer_engine);
end
endmodule
