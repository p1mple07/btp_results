module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/APBGlobalHistoryRegister.fst");
    $dumpvars(0, APBGlobalHistoryRegister);
end
endmodule
