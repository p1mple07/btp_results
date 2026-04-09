   component testing_fsm is
       port (
           clk, rst : in std_logic;
           test_inputs_x1 : in unsigned(3 downto 0);
           test_inputs_x2 : in unsigned(3 downto 0);
           test_expected_outputs : in std_logic_vector(3 downto 0) array;
           gate_select : in std_logic_vector(1 downto 0);
           test_done : out std_logic;
           test_result : out std_logic_vector(3 downto 0);
           test_done_out : out std_logic;
           test_result_out : out std_logic_vector(3 downto 0)
       );
   end component;
   