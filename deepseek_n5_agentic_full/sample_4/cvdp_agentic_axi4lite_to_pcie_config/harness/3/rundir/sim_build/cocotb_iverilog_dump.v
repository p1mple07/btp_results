module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axi4lite_to_pcie_cfg_bridge.fst");
    $dumpvars(0, axi4lite_to_pcie_cfg_bridge);
end
endmodule
