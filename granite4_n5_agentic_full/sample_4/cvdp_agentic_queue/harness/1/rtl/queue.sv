module queue #(
   parameter int Depth = 8, // Number of entries in the queue
   parameter int Bits  = 32 // Width of each entry
) (
   input wire clk_i,    // Clock signal
   input wire rst_ni,   // Asynchronous active-low reset
   input wire clr_i,    // Synchronous clear signal

   input wire ena_i,    // Enable signal for write operations
   input wire we_i,     // Write enable signal
   input wire [Bits-1:0] d_i, // Write data input

   input wire re_i,     // Enable signal for read operations
   output wire [Bits-1:0] q_o, // Read data output

   output wire empty_o, // Empty flag indicating no valid data
   output wire full_o,  // Full flag indicating maximum capacity reached
   output wire [Depth-1:0] count_o // Current count of valid data entries
);

   localparam int AlmostEmptyThreshold = Depth / 4;
   localparam int AlmostFullThreshold = Depth * 3 / 4;

   reg [Depth-1:0] ptr; // Pointer to track valid data entries
   reg [Bits-1:0] storage [Depth-1:0]; // Array to store data

   assign empty_o = (ptr == 0);
   assign full_o = (ptr == Depth);

   always @(posedge clk_i or posedge rst_ni) begin
      if (!rst_ni) begin
         ptr <= 0;
      end else if (clr_i) begin
         ptr <= 0;
      } else if (we_i &&!full_o) begin
         ptr <= (ptr + 1) % Depth;
         storage[ptr] <= d_i;
      end else if (re_i &&!empty_o) begin
         ptr <= (ptr + 1) % Depth;
      end
   end

   assign q_o = storage[ptr];

   assign count_o = ptr;
endmodule