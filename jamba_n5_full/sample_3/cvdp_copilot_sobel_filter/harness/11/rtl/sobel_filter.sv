reg signed [10:0] Gx, Gy;  // To accommodate larger values after convolution
reg [7:0] pixel_buffer[0:8]; // 3x3 pixel window
integer i;
