module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/interrupt_controller.fst");
    $dumpvars(0, interrupt_controller);
end
endmodule
