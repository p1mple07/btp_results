module implements the sorting of an unsigned integer array using a bubble sorting algorithm by repeatedly swapping adjacent elements if they are in the wrong order until the list is sorted. This process continues in multiple passes through the list, with each pass moving the largest unsorted element to its correct position at the end. Modify the code to implement the sorting using insertion sort algorithm."

We need to modify the code. Let's plan modifications:

Insertion sort algorithm: 
- We iterate over the array from index 1 to N-1. For each element, we store it in a temporary variable, say "key", and then compare with previous sorted portion. We shift all elements that are greater than key one position to the right, then insert key at the appropriate index.

We are given that the code uses FSM with states: IDLE, SORTING, DONE. We need to modify the SORTING state to implement insertion sort. Also, the given code uses two registers i and j for bubble sort. We need to use a different indexing scheme.

Let's design insertion sort FSM:
- In IDLE state, if start is high, then we load the array from in_data, then move to a new state, say SORTING, where we start sorting. But insertion sort: we need to process each element from index 1 to N-1. So we need a counter for the current element index, let's call it "k". And a pointer "j" for shifting.

Plan: Insertion sort: 
For each element starting from index 1 to N-1:
   key = array[k]
   j = k-1
   while (j >=0 and array[j] > key) do:
         array[j+1] = array[j]
         j = j-1
   array[j+1] = key

We need to model that in FSM. We have a clock cycle to process each element. But we must follow latency distribution:
"Latency considerations:
- 1 clock cycle to set up the start conditions after the start is asserted high.
- Following will occur for every element in the array:
   - 1 clock cycle to access the element in the array to be sorted.
   - Every shift operation (till the correct spot is found for that element) will take 1 clock cycle.
   - 1 clock cycle to detect iterations for that element is complete.
   - Inserting the element at the spot found will take 1 clock cycle.
- 1 clock cycle to detect that all elements are sorted.
- 1 clock cycle to output the sorted array and assert the done signal."

For example: For input [0,1,2,3], latency = 18 cycles.

Let's design FSM:
We have states: IDLE, SORTING, DONE.
We need to add a counter for the current index to sort. Let's call it "k", range 1 to N-1 (we already have index 0 as sorted). So we need a register "k" maybe. We'll use "k" as insertion index. And we need a register "j" to shift elements.

We have two phases for each element:
Phase 1: Access the element at index k. Save it in a temporary register "key".
Phase 2: Compare and shift:
   While (j >= 0 and array[j] > key) shift.
But we need to implement it in FSM. We can use a sub-state for shifting, maybe use a separate FSM state for shifting.

Let's design FSM states:
- IDLE: Wait for start, load array.
- SORTING: then in SORTING state, we do insertion sort.
We can implement state machine with multiple sub-states inside SORTING:
   Let's define:
      SORTING: main state
         Sub-state: ACCESS: load element key from array[k] into a temporary variable.
         Then move to SHIFT state.
      SHIFT: compare array[j] with key, if array[j] > key then shift array[j] to array[j+1] and decrement j. If condition false, then go to INSERT state.
      INSERT: insert key at position j+1.
      UPDATE: increment k for next element.
   And then if k == N-1 then sorting done, go to DONE.

We need to incorporate the latency cycles as described:
   For each element:
     1 cycle: Access the element (store in key)
     then shifting cycles: each shift operation is 1 cycle, then 1 cycle for iteration complete detection, then 1 cycle to insert element, then 1 cycle to update iteration.
   But these cycles are not explicitly needed to be modeled in the FSM as long as we ensure that each operation takes one cycle. But the FSM transitions are one cycle each. So each state is one clock cycle. 
   We need to model the shifting loop: while j >= 0 and array[j] > key, then shift. But since we are in an FSM, we need to re-read array[j] each cycle.
   But note: The code uses "array" as a register array. We need to be careful with concurrent assignments. We are in procedural block always @(posedge clk) for state transitions. We need to update "array" registers sequentially.
   But insertion sort is sequential algorithm. We can implement it in sequential always block. But the original code is already using FSM with states. We need to replicate that structure.

We can define new state encoding. Let's define:
   localparam IDLE = 3'd0,
              ACCESS = 3'd1,
              SHIFT = 3'd2,
              INSERT = 3'd3,
              UPDATE = 3'd4,
              DONE = 3'd5; 
   We can use 3-bit state encoding.

We need registers: state, next_state, and counters: k for the current index being inserted, j for shifting pointer, and temporary variable key. 
   Let's define: reg [WIDTH-1:0] key; // temporary storage for element being inserted.
   And registers: reg [$clog2(N)-1:0] k; // from 1 to N-1.
   And reg [$clog2(N)-1:0] j; // shifting pointer, initially k-1.

Algorithm:
   In ACCESS state: 
      key = array[k] (for k from 1 to N-1).
      Set j = k - 1.
      Transition to SHIFT state.

   In SHIFT state:
      if (j >= 0 and array[j] > key) then do shift:
         array[j+1] = array[j];
         j = j - 1;
         Remain in SHIFT state.
      else (if j < 0 or array[j] <= key) then transition to INSERT state.

   In INSERT state:
      array[j+1] = key;  // Insert key at j+1.
      Then transition to UPDATE state.

   In UPDATE state:
      k = k + 1;
      if (k == N) then sorting complete, go to DONE state.
      else go to ACCESS state for next element.

   Also, in DONE state:
      Output sorted array: for m=0 to N-1, out_data bits assigned.
      Set done = 1.
      And then transition back to IDLE.

But careful: The original FSM had a separate always block for state transitions. We can modify that. The bubble sort had two always blocks: one combinational always block for next_state, and one always block for sequential update on posedge clk. We can do similar for insertion sort.

We need to check reset behavior. On reset, state <= IDLE, k <= 0, j <= 0, done <= 0, and array loaded? Actually, array is loaded in IDLE if start is asserted.

But careful: The original code loads array in IDLE state if start is asserted. So in our design, we will do that in IDLE. But then we need to start sorting. We can have a signal "start" that triggers state transition from IDLE to ACCESS maybe. But insertion sort requires initial state: IDLE loads array, then goes to ACCESS for first insertion element (k=1) if start is asserted.

But the original code in IDLE: if (start) then load array and set i=0, j=0. We want to do similar: if (start) then load array, then set k=1, j=0, and then state becomes ACCESS.

We need to decide the ordering: In IDLE state, if start, then load array. But in bubble sort code, the array is loaded in always block in IDLE state. But we want to do that too. But then we want to start sorting: So we want to go to ACCESS state if start is asserted. But in bubble sort code, in IDLE, the code does "if (start) begin ... end" but then does not change state. Actually, in bubble sort, in IDLE state, if (start) then load array, set i=0, j=0. But then state remains IDLE, and then next_state gets updated in combinational block: if (start) then next_state = SORTING. So then next_state becomes SORTING. So similarly, we want: if (start) in IDLE, then load array, set k=1, j=0, and then state becomes ACCESS. But careful: In our FSM, we want to go to ACCESS state. But our state encoding: IDLE = 0, ACCESS = 1, etc. So we can do that.

So in IDLE state, on posedge clk, if rst then state<=IDLE else if (start) then state<=ACCESS, load array, set k=1, j=0, done=0.

But careful: The bubble sort code had two always blocks: one combinational always block for next_state and one sequential always block. We can modify the sequential always block to include our new states.

We need to define our state encoding. Let's define localparams:
   localparam IDLE = 3'd0;
   localparam ACCESS = 3'd1;
   localparam SHIFT = 3'd2;
   localparam INSERT = 3'd3;
   localparam UPDATE = 3'd4;
   localparam DONE = 3'd5;

We need to update the state transition logic accordingly.

Let's plan the combinational always block for next_state. We'll have case (state). For each state:

Case IDLE:
   if (start) then next_state = ACCESS; else next_state = IDLE.

Case ACCESS:
   next_state = SHIFT; (after reading key, we go to SHIFT)

Case SHIFT:
   if (j >= 0 and array[j] > key) then next_state = SHIFT; else next_state = INSERT.

Case INSERT:
   next_state = UPDATE; (after insertion, update)

Case UPDATE:
   if (k == N) then next_state = DONE; else next_state = ACCESS;

Case DONE:
   next_state = IDLE; (or maybe remain DONE? But specification says 1 clock cycle to output sorted array and assert done, so then go to IDLE)

That covers all states.

Now the sequential always block @(posedge clk or posedge rst) block. We'll have assignments for each state. We'll need to update registers accordingly.

We have registers: state, k, j, done, key.
We have array which is already declared as "reg [WIDTH-1:0] array [0:N-1];".

We need to update array in the shifting and insertion states.

Let's write the code:

always @(*) begin
    next_state = state; // default
    case (state)
       IDLE: begin
          if (start)
             next_state = ACCESS;
          else
             next_state = IDLE;
       end
       ACCESS: begin
          next_state = SHIFT;
       end
       SHIFT: begin
          if (j >= 0 && array[j] > key)
             next_state = SHIFT;
          else
             next_state = INSERT;
       end
       INSERT: begin
          next_state = UPDATE;
       end
       UPDATE: begin
          if (k == N)
             next_state = DONE;
          else
             next_state = ACCESS;
       end
       DONE: begin
          next_state = IDLE;
       end
       default: next_state = IDLE;
    endcase
end

Now sequential always block @(posedge clk or posedge rst). In that block, if rst then state <= IDLE, k <= 0, j <= 0, done <= 0; Also, array remains unchanged.
If not reset, then:
   state <= next_state;
   Then case (state) inside sequential always block:
   For IDLE: if (start) then load array from in_data. But careful: In bubble sort, the code did:
         for (int k = 0; k < N; k = k + 1) begin
            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
         end
         i <= 0; j <= 0;
      But now we want: load array, then set k = 1, j = 0.
   So in IDLE: if (start) then for (int i = 0; i < N; i++) array[i] = in_data segment. And then set k = 1, j = 0, done = 0.
   But careful: We already in IDLE, if start then next_state becomes ACCESS. So in sequential block, we need to do the loading.
   But the bubble sort code in IDLE did: if (start) begin ... end. So we do similar: if (start) then load array, and set k=1 and j=0.
   But then state becomes ACCESS in next clock cycle. But we want to combine the loading and state transition in one cycle? But the original code did that. But we can do that in sequential always block if start is high.
   But careful: In sequential always block, we can't check "if (start)" because it is synchronous. But we can check if (state == IDLE && start) then load array, set k=1, j=0, and state will be updated to ACCESS in next_state combinational block. But then the assignments for state come after combinational always block. But we want to load array in the same cycle as state transition? The original code did that in the always block on posedge clk. But then the state update is done concurrently. But it's not a problem if we load array in the same cycle as state transition, because then in next cycle, state becomes ACCESS.
   But careful: The original code did "if (start) begin" inside always block. But then the state is updated to next_state. But then the assignments in that block are not visible until next clock cycle? But that is acceptable.

   So in sequential block, case IDLE: if (start) then do loading, set k=1, j=0, done <= 0.
   But what if start is not asserted? Then do nothing.

   For ACCESS state: In ACCESS state, we want to load key from array[k]. So key <= array[k]. But careful: We want to access element at index k. But note: k starts at 1. So in ACCESS, do: key <= array[k]; j <= k - 1; (and maybe leave k unchanged for now, because we want to use j for shifting). But in our design, we want to set j = k - 1. But careful: k is a reg. So in ACCESS state, assign: key <= array[k]; j <= k - 1.
   But note: "k - 1" might be a bit tricky if k is a vector. But that's fine.

   For SHIFT state: In SHIFT state, if condition (j >= 0 and array[j] > key) then do: array[j+1] <= array[j]; j <= j - 1; else nothing.
   But careful: We want to check condition in combinational block. But here we want to perform the shifting if condition holds.
   So in SHIFT state: if (j >= 0 && array[j] > key) then array[j+1] <= array[j] and j <= j - 1; else do nothing.
   But we want to ensure that if condition fails, then state will transition to INSERT next cycle (by combinational block) and we do nothing in SHIFT state. But then in INSERT state, we want to assign array[j+1] <= key.

   For INSERT state: In INSERT state, do: array[j+1] <= key.
   For UPDATE state: In UPDATE state, do: k <= k + 1.
   For DONE state: In DONE state, do: for (int m = 0; m < N; m++) out_data segment <= array[m]; done <= 1; and maybe also reset done? But then state will become IDLE next cycle.
   But careful: The original code in DONE state did the loop in always block. But we can do that.

   Also, in sequential always block, we want to update state <= next_state at the end of always block.

   But careful: In sequential always block, we want to check current state and perform actions accordingly.
   We can use a case statement on state. But note: The assignments for state update should be done outside the case statement. But then we want to do a case statement on current state.
   But be careful: The code in sequential always block is synchronous and we want to check state value from previous cycle. But our combinational always block computed next_state based on previous state. So that's fine.

   Also, note that in SHIFT state, the condition is already computed in combinational always block. But we need to do the shifting operations only if condition holds.

   So structure sequential always block:
       always @(posedge clk or posedge rst) begin
         if (rst) begin
             state <= IDLE;
             k <= 0;
             j <= 0;
             done <= 0;
         end else begin
             state <= next_state;
             case (state)  // note: we want to use the current state value?
             But careful: We want to perform actions based on the state that was executed this cycle. But our state update is done concurrently. But we want to use the previous state value? 
             But in synchronous design, we want to use the current state value (which is the old state value before update). But our sequential block has state <= next_state; and then we use state in a case statement. But that might cause race conditions because state is updated concurrently.
             We can use a temporary variable "current_state" that holds the old state, or we can use a separate register for state that lags behind.
             But in our code, we can do: case (state) where state is the old value because it's registered and updated concurrently. But because state is updated concurrently, the old value is what we want to use for actions. But we must not use the updated state in the same block.
             But in SystemVerilog, the default behavior is that all sequential assignments occur concurrently, so state is updated concurrently and then used in the same always block? That might lead to using the new value instead of the old value. 
             We can solve that by using a separate register for state that lags one cycle. But our original code did: state <= next_state; then in the same block, case (state) and do actions. But that uses the new value of state, which is not what we want.
             The correct approach is to use a temporary register "curr_state" that holds the old state. 
             Alternatively, we can restructure the sequential block so that we compute actions based on next_state. But then we want actions to occur on the current state, not next_state.
             The original code uses a two always blocks: one combinational block for next_state, and one sequential always block that uses the old state. But then they use "case (state)" inside the sequential always block. But then state is updated concurrently, so the actions happen on the old state's value. 
             But in SystemVerilog, the order of evaluation in sequential always block is not guaranteed. However, it's common practice to use the registered state from previous cycle, but then we need to store it in a separate register.
             We can do: reg [2:0] state_reg; then in sequential block: if (rst) state_reg <= IDLE; else state_reg <= state; and then use state_reg in case statement. But then we have two state registers, one computed in combinational always block and one in sequential always block.
             Alternatively, we can structure the sequential always block as:
                 always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        state <= IDLE;
                        ...
                    end else begin
                        case (state) // but here state is the old value because it's registered? But because of non-blocking assignments, all assignments are concurrent, so state is updated concurrently. 
                        endcase
                        state <= next_state;
                    end
                 end
             That might work because state is assigned at the end, so within the case statement, state still holds the old value.
             But careful: In SystemVerilog, all non-blocking assignments are updated concurrently at the end of the clock cycle. So the old value of state is still available for the case statement if we do it before the assignment to state.
             So we can do:
                 always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        state <= IDLE;
                        k <= 0;
                        j <= 0;
                        done <= 0;
                    end else begin
                        case (state)
                           IDLE: begin
                                if (start) begin
                                   // load array from in_data
                                   for (int i = 0; i < N; i = i + 1) begin
                                       array[i] <= in_data[(i+1)*WIDTH-1 -: WIDTH];
                                   end
                                   k <= 1;
                                   j <= 0;
                                   done <= 0;
                                end
                           end
                           ACCESS: begin
                                key <= array[k];
                                j <= k - 1;
                           end
                           SHIFT: begin
                                if (j >= 0 && array[j] > key) begin
                                    array[j+1] <= array[j];
                                    j <= j - 1;
                                end
                           end
                           INSERT: begin
                                array[j+1] <= key;
                           end
                           UPDATE: begin
                                k <= k + 1;
                           end
                           DONE: begin
                                // output sorted array
                                for (int m = 0; m < N; m = m + 1) begin
                                    out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                                end
                                done <= 1;
                           end
                           default: ;
                        endcase
                        state <= next_state;
                    end
                 end

             That should work.

   But careful: In SHIFT state, the condition check is performed in combinational always block already, but we want to perform shifting only if condition holds. But we already check in combinational always block. But we want to perform the shift in SHIFT state if condition holds. But our sequential block in SHIFT state: if (j >= 0 && array[j] > key) then shift. But that's redundant because next_state already computed. But we need to perform the shift operation regardless, because the FSM is designed to be one cycle per operation. So that's fine.

   Also, in ACCESS state, we set key <= array[k] and j <= k - 1. But then what if k==0? But we start from k=1. So that's fine.

   So that's the plan.

   Also, the bubble sort code used "for (int k = 0; k < N; k = k + 1)" for loading array. We'll do similar.

   Also, need to declare key register: reg [WIDTH-1:0] key;.

   Also, need to update the state encoding to be 3 bits: reg [2:0] state, next_state; But original code used "reg [1:0] state, next_state;" for bubble sort. For insertion sort, we need more states. So we use 3 bits.

   And for counters k and j, we use [$clog2(N)-1:0] registers. That remains same.

   And then we update the always @(*) block for next_state.

   So overall, modified code:

   module sorting_engine #(
       parameter N = 8, 
       parameter WIDTH = 8
   )(
       input  wire                clk,
       input  wire                rst,
       input  wire                start,
       input  wire [N*WIDTH-1:0]  in_data,
       output reg                 done,
       output reg [N*WIDTH-1:0]   out_data
   );

       // Internal registers to hold the array
       reg [WIDTH-1:0] array [0:N-1];

       // FSM states for insertion sort
       localparam IDLE    = 3'd0;
       localparam ACCESS  = 3'd1;
       localparam SHIFT   = 3'd2;
       localparam INSERT  = 3'd3;
       localparam UPDATE  = 3'd4;
       localparam DONE    = 3'd5;

       reg [2:0] state, next_state;

       // Counters for insertion sort
       reg [$clog2(N)-1:0] k; // current index to insert, range 1 to N-1
       reg [$clog2(N)-1:0] j; // shifting pointer

       // Temporary variable to hold the element to be inserted
       reg [WIDTH-1:0] key;

       // Next state logic (combinational)
       always @(*) begin
           next_state = state;
           case (state)
               IDLE: begin
                   if (start)
                       next_state = ACCESS;
                   else
                       next_state = IDLE;
               end
               ACCESS: begin
                   next_state = SHIFT;
               end
               SHIFT: begin
                   if (j >= 0 && array[j] > key)
                       next_state = SHIFT;
                   else
                       next_state = INSERT;
               end
               INSERT: begin
                   next_state = UPDATE;
               end
               UPDATE: begin
                   if (k == N)
                       next_state = DONE;
                   else
                       next_state = ACCESS;
               end
               DONE: begin
                   next_state = IDLE;
               end
               default: next_state = IDLE;
           endcase
       end

       // FSM sequential logic
       always @(posedge clk or posedge rst) begin
           if (rst) begin
               state   <= IDLE;
               k       <= 0;
               j       <= 0;
               done    <= 0;
           end else begin
               case (state)
                   IDLE: begin
                       if (start) begin
                           // Load the array from in_data
                           for (int i = 0; i < N; i = i + 1) begin
                               array[i] <= in_data[(i+1)*WIDTH-1 -: WIDTH];
                           end
                           k <= 1; // start insertion from index 1
                           j <= 0;
                           done <= 0;
                       end
                   end
                   ACCESS: begin
                       // Load the element to be inserted into key
                       key <= array[k];
                       j <= k - 1;
                   end
                   SHIFT: begin
                       // Shift elements to the right until correct position is found
                       if (j >= 0 && array[j] > key) begin
                           array[j+1] <= array[j];
                           j <= j - 1;
                       end
                   end
                   INSERT: begin
                       // Insert the key at the correct position
                       array[j+1] <= key;
                   end
                   UPDATE: begin
                       // Move to the next element to be inserted
                       k <= k + 1;
                   end
                   DONE: begin
                       // Output the sorted array
                       for (int m = 0; m < N; m = m + 1) begin
                           out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                       end
                       done <= 1;
                   end
                   default: ;
               endcase
               state <= next_state;
           end
       end

   endmodule