module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/apb_dsp_unit.fst");
    $dumpvars(0, apb_dsp_unit);
end
endmodule
