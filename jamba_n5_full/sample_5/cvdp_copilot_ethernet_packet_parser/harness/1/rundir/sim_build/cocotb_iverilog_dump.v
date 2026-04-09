module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/field_extract.fst");
    $dumpvars(0, field_extract);
end
endmodule
