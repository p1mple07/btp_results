module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/secure_read_write_register_bank.fst");
    $dumpvars(0, secure_read_write_register_bank);
end
endmodule
