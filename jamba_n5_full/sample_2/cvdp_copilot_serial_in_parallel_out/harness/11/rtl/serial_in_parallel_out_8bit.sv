entity serpo is
    generic (
        DATA_WIDTH : positive := 16;
        SHIFT_DIRECTION : std_logic := '1';
        CODE_WIDTH : positive := 21
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        serial_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        shift_en : in std_logic;
        done : out std_logic;
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        parallel_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        encoded : out std_logic_vector(CODE_WIDTH - 1 downto 0);
        received : in std_logic_vector(CODE_WIDTH - 1 downto 0);
        error_detected : out std_logic;
        error_corrected : out std_logic
    );
end serpo;
