module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/image_stego.fst");
    $dumpvars(0, image_stego);
end
endmodule
