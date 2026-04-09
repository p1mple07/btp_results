module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pcie_endpoint.fst");
    $dumpvars(0, pcie_endpoint);
end
endmodule
