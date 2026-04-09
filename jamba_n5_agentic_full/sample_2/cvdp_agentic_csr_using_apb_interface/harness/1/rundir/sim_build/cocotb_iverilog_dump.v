module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/csr_apb_interface.fst");
    $dumpvars(0, csr_apb_interface);
end
endmodule
