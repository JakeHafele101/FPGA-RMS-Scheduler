library IEEE;
use IEEE.std_logic_1164.all;

entity dataflow_mux2t1 is

  port(i_A                         : in std_logic;
       i_B                         : in std_logic;
       i_Sel                         : in std_logic;
       o_Out                         : out std_logic);

end dataflow_mux2t1;

architecture dataflow of dataflow_mux2t1 is
begin
    o_Out <= i_A when (i_Sel = '0') else i_B;
end dataflow;
