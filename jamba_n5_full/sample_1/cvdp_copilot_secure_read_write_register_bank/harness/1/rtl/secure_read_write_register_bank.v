module secure_read_write_register_bank(
    input  wire i_rst_n,
    input  wire i_addr,
    input  wire i_data_in,
    input  wire i_read_write_enable,
    input  wire i_capture_pulse,
    input  wire i_data_out,
    output reg o_data_out
);
