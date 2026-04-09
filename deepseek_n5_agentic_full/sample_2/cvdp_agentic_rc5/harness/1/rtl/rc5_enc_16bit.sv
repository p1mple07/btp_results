module rc5_enc_16bit(
	input clock,
	input reset,
	input enc_start,
	input [15:0] p,
	output [15:0] c,
	output enc_done
)
	parameter W = 8;
	parameter CH = 2*W; // 16-bit block size
	parameter SR = 2*(CH/8); // Number of S-boxes: 4
    
	wire [SR-1:0] s_box;
	wire [CH-1:0] a, b, c, d;
	wire [SR-1:0] q1, q2, q3, q4, q5, q6, q7, q8;
	
	// Initialize S-boxes using CA_1
	// Extract q1-q8 from CA_1 and map to s_box[0-3]
	assign s_box[0] = q1;
	assign s_box[1] = q2;
	assign s_box[2] = q3;
	assign s_box[3] = q4;
	
	// FSM state variables
 Reg state = 0;
 Reg valid = 0;
	
	// Initialisation phase
	always @+ begin
		if (reset == 1 && enc_start == 1) begin
			// Load the plaintext into A and B
			a = (p >> 8) & 0xFF;
			b = p & 0xFF;
			
			// Perform initial additions
			a = (a + s_box[0]) % 256;
			b = (b + s_box[1]) % 256;
			
			// Set state to processing MSB
			state = 1;
			valid = 1;
		end else if (state == 1) begin
			// Processing MSB
			// Calculate new_a and new_b
			int temp_a = a ^ b;
			int temp_b = a;
			temp_a = (temp_a << b) % 256;
			temp_b = (temp_b << a) % 256;
			new_a = (temp_a + s_box[2]) % 256;
			new_b = (temp_b + s_box[3]) % 256;
			
			// Update state
			state = 2;
			a = new_a;
			b = new_b;
			valid = 1;
		end else if (state == 2) begin
			// Processing LSB
			// Calculate new_a and new_b
			int temp_a = a ^ b;
			int temp_b = a;
			temp_a = (temp_a << b) % 256;
			temp_b = (temp_b << a) % 256;
			new_a = (temp_a + s_box[0]) % 256;
			new_b = (temp_b + s_box[1]) % 256;
			
			// Update state and ciphertext
			state = 3;
			c = (new_a << 8) | new_b;
			valid = 1;
		end else if (state == 3) begin
			// Final output
			valid = 0;
		end
		end