module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/APBGlobalHistoryRegister_secure_top.fst");
    $dumpvars(0, APBGlobalHistoryRegister_secure_top);
end
endmodule
