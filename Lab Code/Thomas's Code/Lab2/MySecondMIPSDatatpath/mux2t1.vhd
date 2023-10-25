library IEEE;
use IEEE.std_logic_1164.all;


entity mux2t1 is

  port(i_D0                         : in std_logic;
       i_D1                         : in std_logic;
       i_S                         : in std_logic;
       o_O                         : out std_logic);

end mux2t1;

architecture structure of mux2t1 is
  
  -- Describe the component entities as defined in andg2.vhd, invg.vhd,
  -- org2.vhd.
  component andg2
    port(i_A          : in std_logic;
    i_B          : in std_logic;
    o_F          : out std_logic);
  end component;

  component invg
    port(i_A          : in std_logic;
    o_F          : out std_logic);
  end component;

  component org2
    port(i_A          : in std_logic;
    i_B          : in std_logic;
    o_F          : out std_logic);
  end component;


  signal s_inv         : std_logic;
  signal s_A, s_B   : std_logic;

begin

  ---------------------------------------------------------------------------
  -- Level 0: invert select
  ---------------------------------------------------------------------------
 
  g_invert: invg
    port MAP(i_A             => i_S,
             o_F               => s_inv);


  ---------------------------------------------------------------------------
  -- Level 1: And Signals with select or inverted select
  ---------------------------------------------------------------------------
  g_AndSigA: andg2
    port MAP(i_A             => i_D0,
             i_B               => s_inv,
             o_F               => s_A);
  
  g_AndSigB: andg2
    port MAP(i_A             => i_D1,
             i_B               => i_S,
             o_F               => s_B);



    
  ---------------------------------------------------------------------------
  -- Level 2: Ors them together
  ---------------------------------------------------------------------------
  g_Or: org2
    port MAP(i_A            => s_A,
             i_B              => s_B,
             o_F               => o_O);
             
  end structure;