module serial_in_parallel_out_8bit (clock, serial_in, parallel_out);
    reg [7:0] reg_data;

    always @(posedge clock) begin
        if (serial_in)
            reg_data <= {reg_data[6:0], serial_in};
        else
            reg_data <= reg_data;
    end

    assign parallel_out = reg_data;
endmodule
