module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/String_to_ASCII_Converter.fst");
    $dumpvars(0, String_to_ASCII_Converter);
end
endmodule
