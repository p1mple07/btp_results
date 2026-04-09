module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/password_generator.fst");
    $dumpvars(0, password_generator);
end
endmodule
