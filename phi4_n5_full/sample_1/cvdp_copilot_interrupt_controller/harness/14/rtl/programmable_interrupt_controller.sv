module interrupt_controller 
#(
    parameter NUM_INTERRUPTS = 4, 
    parameter ADDR_WIDTH = 8
)
(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    input  logic [NUM_INTERRUPTS-1:0] priority_map_value [NUM_INTERRUPTS-1:0],
    input  logic                      priority_map_update,
    input  logic [ADDR_WIDTH-1:0]     vector_table_value [NUM_INTERRUPTS-1:0],
    input  logic                      vector_table_update,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_mask_value,
    input  logic                      interrupt_mask_update
);

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------
  // Pending interrupts: OR of new requests with previously pending ones.
  reg [NUM_INTERRUPTS-1:0] pending_interrupts;
  
  // Internal interrupt mask register.
  reg [NUM_INTERRUPTS-1:0] internal_interrupt_mask;
  
  // Current serviced interrupt index. Using an integer variable.
  integer current_interrupt;
  
  // Priority map: a 2D array. For simplicity, we use the diagonal elements as the
  // effective priority for each interrupt. (priority_map[i][i] holds the priority of interrupt i)
  reg [NUM_INTERRUPTS-1:0] priority_map [NUM_INTERRUPTS-1:0];
  
  // Interrupt vector table.
  reg [ADDR_WIDTH-1:0] vector_table [NUM_INTERRUPTS-1:0];

  //-------------------------------------------------------------------------
  // Sequential Logic
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset all state registers.
      pending_interrupts          <= '0;
      internal_interrupt_mask     <= '0;
      current_interrupt           <= 0;
      
      // Initialize the priority map with default sequential priorities.
      integer i, j;
      for (i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
        for (j = 0; j < NUM_INTERRUPTS; j = j + 1) begin
          if (i == j)
            priority_map[i][j] <= i;  // Default: interrupt i gets priority = i
          else
            priority_map[i][j] <= 0;  // Non-diagonal entries are not used.
        end
      end
      
      // Initialize the vector table with default vectors (multiples of 4).
      for (i = 0; i < NUM_INTERRUPTS; i = i + 1)
        vector_table[i] <= i * 4;
        
    end
    else begin
      //-------------------------------------------------------------------------
      // Dynamic Updates
      //-------------------------------------------------------------------------
      if (priority_map_update) begin
        integer i, j;
        for (i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
          for (j = 0; j < NUM_INTERRUPTS; j = j + 1)
            priority_map[i][j] <= priority_map_value[i][j];
        end
      end
      
      if (vector_table_update) begin
        integer i;
        for (i = 0; i < NUM_INTERRUPTS; i = i + 1)
          vector_table[i] <= vector_table_value[i];
      end
      
      if (interrupt_mask_update)
        internal_interrupt_mask <= interrupt_mask_value;
      
      //-------------------------------------------------------------------------
      // Update Pending Interrupts
      //-------------------------------------------------------------------------
      // An interrupt remains pending until it is serviced and acknowledged.
      pending_interrupts <= pending_interrupts | interrupt_requests;
      
      //-------------------------------------------------------------------------
      // Servicing Logic
      //-------------------------------------------------------------------------
      // If an interrupt is currently being serviced and the CPU has acknowledged it,
      // clear that interrupt from the pending queue.
      if (current_interrupt != 0 && cpu_ack) begin
        pending_interrupts[current_interrupt] <= 0;
        current_interrupt <= 0;
      end
      // If no interrupt is being serviced, select the highest priority pending
      // interrupt that is not masked.
      else if (current_interrupt == 0) begin
        integer i;
        logic [31:0] min_priority;  // Use a wider type for comparison.
        integer selected;
        // Initialize min_priority to a value higher than any valid priority.
        min_priority = NUM_INTERRUPTS;
        selected = -1;
        for (i = 0; i < NUM_INTERRUPTS; i = i + 1) begin
          if (pending_interrupts[i] && ~internal_interrupt_mask[i]) begin
            // Effective priority is taken from the diagonal element.
            if (priority_map[i][i] < min_priority) begin
              min_priority = priority_map[i][i];
              selected = i;
            end
          end
        end
        if (selected != -1)
          current_interrupt <= selected;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Combinational Outputs
  //-------------------------------------------------------------------------
  // Set the interrupt_service vector to have a '1' at the index of the current interrupt.
  assign interrupt_service = (current_interrupt != 0) ? (1 << current_interrupt) : 0;
  
  // Assert cpu_interrupt if an interrupt is being serviced.
  assign cpu_interrupt = (current_interrupt != 0);
  
  // Output the index of the currently serviced interrupt.
  assign interrupt_idx = current_interrupt[clog2(NUM_INTERRUPTS)-1:0];
  
  // Output the interrupt vector corresponding to the current interrupt.
  assign interrupt_vector = vector_table[current_interrupt];

endmodule