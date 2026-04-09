module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output        m0_read  ,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output        m1_read  ,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output        s_valid  ,
  output [31:0] s_data 
);

  // State variables
  reg m0_state = 0; // 0: idle, 1: processing m0, 2: busy
  reg m1_state = 0; // 0: idle, 1: processing m1, 2: busy
  reg s_state = 0;  // 0: idle, 1: processing

  // slave side
  always @posedge rst_n) begin
    if (s_state == 0)
      s_state = 1;
  end

  // master 0
  always @posedge rst_n) begin
    if (m0_state == 0 & m0_valid) begin
      case (m0_state)
        0: m0_state = 1;
        1: m0_state = 2;
      endcase
    end
  end

  // master 1
  always @posedge rst_n) begin
    if (m1_state == 0 & m1_valid) begin
      case (m1_state)
        0: m1_state = 1;
        1: m1_state = 2;
      endcase
    end
  end

  // slave
  always @posedge rst_n) begin
    if (s_state == 0 & s_read) begin
      s_state = 1;
      s_valid = 1;
    end
  end

  // master 0
  always @posedge rst_n) begin
    if (m0_state == 2) begin
      if (m0_valid) begin
        case (m0_state)
          2: begin
            // gate data and valid
            m0_valid = 0;
            m0_data = 0;
          end
        end
      end
    end
  end

  // master 1
  always @posedge rst_n) begin
    if (m1_state == 2) begin
      if (m1_valid) begin
        case (m1_state)
          2: begin
            // gate data and valid
            m1_valid = 0;
            m1_data = 0;
          end
        end
      end
    end
  end

  // slave
  always @posedge rst_n) begin
    if (s_state == 1) begin
      if (s_valid) begin
        s_valid = 0;
        s_data = 0;
        s_state = 0;
        // send to m0 or m1 based on AFINITY
        case (s_state)
          0: begin
            m0_read = 1;
            m1_read = 0;
          end
          1: begin
            m0_read = 0;
            m1_read = 1;
          end
        end
      end
    end
  end
endmodule