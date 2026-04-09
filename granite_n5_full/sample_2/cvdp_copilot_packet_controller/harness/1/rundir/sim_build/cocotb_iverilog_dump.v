module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/packet_controller.fst");
    $dumpvars(0, packet_controller);
end
endmodule
