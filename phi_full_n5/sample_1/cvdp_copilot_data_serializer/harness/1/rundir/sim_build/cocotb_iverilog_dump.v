module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/data_serializer.fst");
    $dumpvars(0, data_serializer);
end
endmodule
