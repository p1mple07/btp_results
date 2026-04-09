module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/apb_controller.fst");
    $dumpvars(0, apb_controller);
end
endmodule
