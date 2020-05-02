LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY room IS
PORT(ir1, ir2 : IN STD_LOGIC;
rst_count: IN STD_LOGIC;
bright : IN STD_LOGIC;
clk : IN STD_LOGIC;
lights : OUT STD_LOGIC;
disp1, disp2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));--------set entry to zero in main entity
END room;

ARCHITECTURE operat OF room IS
SIGNAL ppl_num1, ppl_num0 : STD_LOGIC_VECTOR(6 DOWNTO 0); ---

SIGNAL enters, exits : STD_LOGIC ; -----ir outputs
SIGNAL  clk_count: STD_LOGIC;

COMPONENT clk_generator
PORT (clk50hz : IN STD_LOGIC; clk1hz : INOUT STD_LOGIC);
END COMPONENT;

COMPONENT light
PORT(
count1, count2: IN STD_LOGIC_VECTOR(6 DOWNTO 0):="0000000";
entry, exits : IN STD_LOGIC:='Z';
clk : IN STD_LOGIC;
bright : IN STD_Logic:='Z';
lightout : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT ppl_count IS
PORT (enters, exits:IN STD_LOGIC:='Z';clk, rst:IN STD_LOGIC; bcd1,bcd0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000000");
END COMPONENT;


BEGIN
clk3: clk_generator PORT MAP(clk,clk_count);
illum : light PORT MAP(ppl_num0, ppl_num1, ir1, ir2, clk_count, bright, lights);
counter : ppl_count PORT MAP(ir1, ir2, clk_count, rst_count,ppl_num1, ppl_num0);
disp1<=ppl_num0;
disp2<=ppl_num1;

END operat;



------------------------------------------------------------------------------------------LIGHT

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY light IS
PORT(
count1, count2: IN STD_LOGIC_VECTOR(6 DOWNTO 0):="0000000";
entry, exits : IN STD_LOGIC:='Z';
clk : IN STD_LOGIC;
bright : IN STD_Logic:='Z';
lightout : OUT STD_LOGIC
);
END light;

ARCHITECTURE behav_light OF light IS
BEGIN

PROCESS (exits, entry, bright, clk)
BEGIN
IF(clk'EVENT AND clk = '1') THEN

IF count1 = NOT"0111111" AND count2 =NOT"0111111"  THEN lightout <='0'; END IF;

IF(exits = '0') THEN
IF count1 = NOT"0111111" AND count2 = NOT"0000110" THEN -- first bcd implies 0 and second bcd implies 1 thus count = 1
  lightout <='0';
END IF; END IF;

IF(entry = '0') THEN
IF bright ='0' THEN
  lightout <='0';
ELSE lightout <='1';
END IF; END IF;

END IF;
END PROCESS;
END behav_light;
-------------------------------------------------------------------------------COUNT--------
library ieee;
USE IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_1164.all;

ENTITY clk_generator IS
PORT (clk50hz : IN STD_LOGIC; clk1hz : INOUT STD_LOGIC);
END clk_generator;

ARCHITECTURE behav_clk_generator OF clk_generator IS
signal count50 : UNSIGNED(27 DOWNTO 0);
BEGIN

PROCESS (clk50hz, count50)
	BEGIN
		IF(clk50hz'EVENT AND clk50hz='1') THEN
			IF count50=X"4C4B40" THEN count50 <= X"0000000";
			ELSE count50 <= count50+"0000001";
			END IF;
		END IF;
		IF count50 =X"0000000" THEN clk1hz <= '1';
		ELSE clk1hz <= '0';
		END IF;
	END PROCESS;

END behav_clk_generator;
---------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ppl_count IS
PORT (enters, exits:IN STD_LOGIC:='Z';clk, rst:IN STD_LOGIC; bcd1,bcd0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000000");
END ppl_count;

ARCHITECTURE behav_count_sync OF ppl_count IS
SIGNAL dig0,dig1 : STD_LOGIC_VECTOR(3 DOWNTO 0):= "0000";
--SIGNAL TEMP : STD_LOGIC;

COMPONENT seven_seg PORT(num:IN STD_LOGIC_VECTOR(3 DOWNTO 0); disp :OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;

--COMPONENT clk_generator PORT (clk50hz : IN STD_LOGIC; clk1hz : OUT STD_LOGIC);
--END COMPONENT;

BEGIN
--clock_2 : clk_generator PORT MAP(clk, temp);

PROCESS(clk, exits, enters)
BEGIN --AND exits /= '0'
	IF clk'EVENT AND clk = '1' AND enters = '0'  AND exits /= '0' AND rst = '0' THEN
	IF dig0="1001" THEN dig1<=dig1+1; dig0<="0000"; ELSE dig0<=dig0+1; END IF;
	ELSIF clk'EVENT AND clk = '1' AND enters /= '0' AND exits = '0' AND rst = '0' THEN
	IF dig0="0000" AND dig1="0000" THEN dig1<=dig1; dig0<=dig0; ELSE
	IF dig0="0000"AND dig1 /="0000" THEN dig1<=dig1-1; dig0<="1001"; ELSE  dig0<=dig0-1; END IF; END IF;
	ELSIF clk'EVENT AND clk = '1' AND enters /= '0' AND exits /= '0' AND rst = '0' THEN dig0<=dig0; dig1<=dig1;
	ELSIF clk'EVENT AND clk = '1' AND rst = '1' THEN dig0<= "0000"; dig1<= "0000";
	END IF;
END PROCESS;
dsp1: seven_seg PORT MAP(dig1, bcd1);
dsp0: seven_seg PORT MAP(dig0, bcd0);

END behav_count_sync;
-------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY seven_seg IS
PORT(num:IN STD_LOGIC_VECTOR(3 DOWNTO 0); disp :OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END seven_seg;

ARCHITECTURE behavior2 OF seven_seg IS
BEGIN
disp <= NOT("0111111") WHEN num="0000" ELSE
		  NOT("0000110") WHEN num="0001" ELSE
		  NOT("1011011") WHEN num="0010" ELSE
		  NOT("1001111") WHEN num="0011" ELSE
		  NOT("1100110") WHEN num="0100" ELSE
		  NOT("1101101") WHEN num="0101" ELSE
		  NOT("1111101") WHEN num="0110" ELSE
		  NOT("0000111") WHEN num="0111" ELSE
		  NOT("1111111") WHEN num="1000" ELSE
		  NOT("1101111") WHEN num="1001" ;
END behavior2;
-----------------------------------------------------------------------------------------------------
