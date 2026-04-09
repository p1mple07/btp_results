module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/serial_line_code_converter.fst");
    $dumpvars(0, serial_line_code_converter);
end
endmodule
