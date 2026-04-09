module sync_serial_communication_tx_rx(
    input         clk,                    
    input         reset_n,                
    input  [2:0]  sel,              
    input  [63:0] data_in,         
    output [63:0] data_out,       
    output        done,
    output        parity,           // Transmitted parity bit from TX block
    output        parity_error      // Parity error detected in RX block
);

// Internal signals
wire tx_out;
wire tx_done;
wire serial_clk_in;

// Instantiate the TX block
tx_block uut_tx_block (
    .clk         (clk),                    
    .reset_n     (reset_n),                
    .data_in     (data_in),         
    .sel         (sel),              
    .serial_out  (tx_out),          
    .done        (tx_done),         
    .serial_clk  (serial_clk_in),   
    .parity      (parity)            // Connect TX parity output to top-level parity
);

// Instantiate the RX block
rx_block uut_rx_block (
    .clk         (clk),                    
    .reset_n     (reset_n),                
    .serial_clk  (serial_clk_in),   
    .data_in     (tx_out),          
    .parity_in   (parity),           // Connect TX parity output to RX parity_in
    .sel         (sel),              
    .done        (done),             
    .data_out    (data_out),        
    .parity_error(parity_error)      // Top-level parity error output
);

endmodule