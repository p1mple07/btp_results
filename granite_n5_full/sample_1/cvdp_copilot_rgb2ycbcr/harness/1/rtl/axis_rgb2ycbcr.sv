module axis_rgb2ycbcr #(
    parameter PIXEL_WIDTH = 16,
    parameter FIFO_DEPTH = 16
)(
    input  wire            aclk,
    input  wire            aresetn,

    // AXI Stream Slave Interface (Input)
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    output wire            s_axis_tready,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,

    // AXI Stream Master Interface (Output)
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    input  wire            m_axis_tready,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser
);

    // -----------------------------
    // FIFO Buffer (16-depth buffer)
    // -----------------------------
    reg [15:0] fifo_data [0:FIFO_DEPTH-1];
    reg        fifo_tlast [0:FIFO_DEPTH-1];
    reg        fifo_tuser [0:FIFO_DEPTH-1];

    reg [3:0] write_ptr, read_ptr; // 4-bit pointers for FIFO
    reg full;
    wire       empty;

    wire       fifo_write = s_axis_tvalid &&!full;
    wire       fifo_read  =!empty && m_axis_tready;

    // -----------------------------
    // FIFO Buffer Write
    // -----------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            write_ptr <= 0;
            full <= 0;
        end
    end

    // -----------------------------
    // FIFO Buffer Read
    // -----------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            read_ptr <= 0;
        end
    end

    // -----------------------------
    // AXI-Stream Output Signals
    // -----------------------------
    assign s_axis_tready =!full; // Only accept data when FIFO is not full
    assign m_axis_tvalid =!empty; // Only transmit when FIFO has data
    assign m_axis_tdata  = fifo_data[read_ptr];
    assign m_axis_tlast  = fifo_tlast[read_ptr];
    assign m_axis_tuser  = fifo_tuser[read_ptr];

endmodule

cd rtl
vlog -work rtl
vlog -work rtl
vlogsim -input rtl/axis_rgb2ycbcr.sv

mkdir testcases/axis_rgb2ycbcr.sv

code.sv
module axis_rgb2ycbcr.sv

module axis_rgb2ycbcr.sv

module axis_rgb2ycbcr.sv
// Create a directory called `testcases/axis_rgb2ycbcr.sv
// Then, create a directory called `testcases/axis_rgb2ycbcr.sv
// Then, create a directory called `testcases/axis_rgb2ycbcr.sv
// Create a directory called `rtl/axis_rgb2ycbcr.sv

module axis_rgb2ycbcr.sv
//...
// 1st line.
    interface rgb2ycbcr_if rgb2ycbcr_interface rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if;

    //...



//...
//...
    //...
    //...
    //...
    //...
    //...
    //...
endmodule rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if rgb2ycbcr_if;

    //...
    //...
    //...
    //...
    //...
    //     }
endmodule