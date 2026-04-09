module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/interrupt_controller_apb.fst");
    $dumpvars(0, interrupt_controller_apb);
end
endmodule
