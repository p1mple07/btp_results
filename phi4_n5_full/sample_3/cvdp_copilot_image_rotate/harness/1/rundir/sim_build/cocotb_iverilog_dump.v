module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/image_rotate.fst");
    $dumpvars(0, image_rotate);
end
endmodule
