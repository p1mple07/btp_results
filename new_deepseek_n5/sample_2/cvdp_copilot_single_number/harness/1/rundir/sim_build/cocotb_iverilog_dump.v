module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/unique_number_identifier.fst");
    $dumpvars(0, unique_number_identifier);
end
endmodule
