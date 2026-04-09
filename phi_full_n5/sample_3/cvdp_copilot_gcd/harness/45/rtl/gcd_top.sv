module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input                     go,
   input [WIDTH-1:0]        A,
   input [WIDTH-1:0]        B,
   output logic [WIDTH-1:0] OUT,
   output logic             done
);

   // Combined control and datapath logic
   always_comb begin
      // Initialize registers
      logic [WIDTH-1:0] A_reg, B_reg, OUT_reg, k_reg, diff_reg, gcd_val_reg;
      logic equal_reg, controlpath_state_reg, done_reg;

      // Reset logic
      if (rst) begin
         A_reg <= B; // Reset A to B
         B_reg <= B; // Reset B to B
         OUT_reg <= B; // Reset OUT to B
         k_reg    <= 0;
         diff_reg <= 0;
         gcd_val_reg <= 0;
         equal_reg  <= 0;
         controlpath_state_reg <= 0;
         done_reg    <= 0;
      end else begin
         // Load inputs
         if (go) begin
            A_reg <= A;
            B_reg <= B;
         end

         // Control path logic
         equal_reg = (A_reg == B_reg);
         if (equal_reg) begin
            OUT_reg <= A_reg;
            done_reg    <= 1;
         end else begin
            // Stein's algorithm steps
            k_reg <= 0;
            diff_reg <= 0;
            gcd_val_reg <= A_reg;

            // Continue processing
            if (k_reg == WIDTH-1) begin
               // Last step, adjust gcd value
               OUT_reg <= gcd_val_reg;
            end else begin
               if (A_reg[k_reg] == 0) begin
                  diff_reg <= A_reg - B_reg;
               end else if (B_reg[k_reg] == 0) begin
                  diff_reg <= B_reg - A_reg;
               end else begin
                  diff_reg <= (A_reg[k_reg] > B_reg[k_reg]) ? A_reg - B_reg : B_reg - A_reg;
               end

               gcd_val_reg <= diff_reg << 1;
               if (A_reg == diff_reg) begin
                  A_reg <= A_reg >> 1;
               end else if (A_reg[k_reg] == 0) begin
                  A_reg <= B_reg;
               end else if (B_reg[k_reg] == 0) begin
                  B_reg <= A_reg;
               end

               k_reg <= k_reg + 1;
            end
         end
      end

   end

   assign OUT = OUT_reg;
   assign done = done_reg;

endmodule
