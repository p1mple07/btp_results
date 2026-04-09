module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/virtual2physical_tlb.fst");
    $dumpvars(0, virtual2physical_tlb);
end
endmodule
