module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/universal_shift_register.fst");
    $dumpvars(0, universal_shift_register);
end
endmodule
