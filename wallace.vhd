-------------half adder cell--------------
library ieee;
use ieee.std_logic_1164.all;

  entity half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
  end half_adder;
  
 architecture HA_arch of half_adder is
  
  begin 
    
  S<= A xor B;
  Cout<=A and B;
   
  end HA_arch;

--------------full adder cell----------------
library ieee;
use ieee.std_logic_1164.all;

entity full_adder is 
               port(A,B,Cin	: in	std_logic;
                   S,Cout	: out	std_logic);
                end full_adder;

architecture FA_arch of full_adder is 

  component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
  end component;
  
  signal s1: std_logic;
  signal s2: std_logic;
  signal s3: std_logic;
  
  begin
    
   step1: half_adder port map (A,B,s1,s2);      
   step2: half_adder port map (Cin,s1,S,s3);
     
     Cout<=s2 or s3;
     
   end FA_arch;
------partial product generator cell--------------
   library ieee;
  use ieee.std_logic_1164.all;
  
  entity prod_gen_cell is
    port (A: in std_logic;
          B: in std_logic_vector(7 downto 0);
          PP: out std_logic_vector(7 downto 0));
        end prod_gen_cell;
        
    architecture prgen_cell_arch of prod_gen_cell is
            begin
             process(A,B)
               begin
                 for i in 0 to 7 loop
                   PP(i)<=A and B(i);
                 end loop;
               end process;
            end prgen_cell_arch;
            
-----------partial product generator--------------
  
library ieee;
  use ieee.std_logic_1164.all;
  
  entity prod_gen is
    PORT (A,B: in std_logic_vector(7 downto 0);
          PP1,PP2,PP3,PP4,PP5,PP6,PP7,PP8: out std_logic_vector(7 downto 0));
  end prod_gen;
  
  architecture prod_gen_arch of prod_gen is
    
    component prod_gen_cell is
    port (A: in std_logic;
          B: in std_logic_vector(7 downto 0);
          PP: out std_logic_vector(7 downto 0));
    end component;
       
      begin
       gen1: prod_gen_cell port map (A(0),B,PP1);
       gen2: prod_gen_cell port map (A(1),B,PP2);
       gen3: prod_gen_cell port map (A(2),B,PP3);
       gen4: prod_gen_cell port map (A(3),B,PP4);
       gen5: prod_gen_cell port map (A(4),B,PP5);
       gen6: prod_gen_cell port map (A(5),B,PP6);
       gen7: prod_gen_cell port map (A(6),B,PP7);
       gen8: prod_gen_cell port map (A(7),B,PP8);
        
  end prod_gen_arch;
  
---------------reduction layer 1------------------
library ieee;
  use ieee.std_logic_1164.all;
  
  entity layer1 is
    PORT( PP1,PP2,PP3,PP4,PP5,PP6: in std_logic_vector (7 downto 0);
          L1,L3:out std_logic_vector(9 downto 0);
          L2,L4: out std_logic_vector(7 downto 0));
  end layer1;
  
  architecture layer1_arch of layer1 is
    
    component full_adder is
      PORT (A,B,Cin: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
    end component;
   
  
  begin 
   --1st step
     A0: L1(0)<=PP1(0);
     A1: half_adder port map(PP1(1),PP2(0),L1(1),L1(2));
     A2: for j in 0 to 5 generate
        mid: full_adder port map(PP1(j+2),PP2(j+1),PP3(j),L2(j),L1(j+3));
        end generate A2;
     A3: half_adder port map(PP2(7),PP3(6),L2(6),L1(9));
     A4: L2(7)<=PP3(7);  
     
   --2nd step
     B0: L3(0)<=PP4(0);
     B1: half_adder port map(PP4(1),PP5(0),L3(1),L3(2));
     B2: for k in 0 to 5 generate
        mid1: full_adder port map(PP4(k+2),PP5(k+1),PP6(k),L4(k),L3(k+3));
        end generate B2;
     B3: half_adder port map(PP5(7),PP6(6),L4(6),L3(9));
     B4: L4(7)<=PP6(7);
     
  end layer1_arch;  

------------------reduction layer 2---------------------
library ieee;
use ieee.std_logic_1164.all;
  
  entity layer2 is
    PORT( F1,F3: in std_logic_vector (9 downto 0);
          F2,F4,F5,F6:in std_logic_vector(7 downto 0);
          SE1:out std_logic_vector(10 downto 0);
          SE2,SE3:out std_logic_vector(9 downto 0);
          SE4:out std_logic_vector(7 downto 0));
  end layer2;
  
  architecture layer2_arch of layer2 is
     component full_adder is
      PORT (A,B,Cin: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    begin
  --1st step
  C0: SE1(0)<=F1(0);
  C1: SE1(1)<=F1(1);
  C2: half_adder port map (F1(2),F2(0),SE1(2),SE1(3));
  C3: for l in 0 to 6 generate
    mid2: full_adder port map (F1(3+l),F2(1+l),F3(l),SE2(l),SE1(4+l));
    end generate C3;
  C4: SE2(7)<=F3(7);
  C5: SE2(8)<=F3(8);
  C6: SE2(9)<=F3(9);
  
  --2nd step
 D0: SE3(0)<=F4(0);
 D1: half_adder port map (F4(1),F5(0),SE3(1),SE3(2));
 D2: for m in 0 to 5 generate
   mid3: full_adder port map (F4(m+2),F5(m+1),F6(m),SE4(m),SE3(m+3));
   end generate D2;
 D3: half_adder port map(F5(7),F6(6), SE4(6), SE3(9));
 D4: SE4(7)<=F6(7);
 
 end layer2_arch;
 
 -------------------reduction layer 3---------------------------
 library ieee;
 use ieee.std_logic_1164.all;
  
  entity layer3 is
    PORT( SE1:in std_logic_vector(10 downto 0);
          SE2,SE3:in std_logic_vector(9 downto 0);
          T1:out std_logic_vector(13 downto 0);
          T2:out std_logic_vector(10 downto 0));
  end layer3;
  
  architecture layer3_arch of layer3 is
     component full_adder is
      PORT (A,B,Cin: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    begin
      
      E0: T1(0)<=SE1(0);
      E1: T1(1)<=SE1(1);
      E2: T1(2)<=SE1(2);
      E3: half_adder port map(SE1(3),SE2(0),T1(3),T1(4));
      E4: half_adder port map(SE1(4),SE2(1),T2(0),T1(5));
      E5: for n in 0 to 5 generate
        mid4: full_adder port map(SE1(n+5),SE2(n+2),SE3(n),T2(n+1),T1(n+6));
        end generate E5;
      E6: half_adder port map(SE2(8),SE3(6),T2(7),T1(12));
      E7: half_adder port map(SE2(9),SE3(7),T2(8),T1(13));
      E8: T2(9)<=SE3(8);
      E9: T2(10)<=SE3(9);
      
    end layer3_arch;
    
    ----------------------reduction layer 4--------------------------
    library ieee;
    use ieee.std_logic_1164.all;
  
  entity layer4 is
    PORT( T1: in std_logic_vector(13 downto 0);
          T2: in std_logic_vector(10 downto 0);
          T3: in std_logic_vector(7 downto 0);
          EX1:out std_logic_vector(15 downto 0);
          EX2:out std_logic_vector(9 downto 0));
  end layer4;
  
  architecture layer4_arch of layer4 is
     component full_adder is
      PORT (A,B,Cin: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
    end component;
    
    begin
    
    F0: EX1(0)<=T1(0);
        EX1(1)<=T1(1);
        EX1(2)<=T1(2);
        EX1(3)<=T1(3);
    F1:half_adder port map(T1(4),T2(0),EX1(4),EX1(5));
    F2:half_adder port map(T1(5),T2(1),EX2(0),EX1(6));
    F3:half_adder port map(T1(6),T2(2),EX2(1),EX1(7));
    F4:for p in 0 to 6 generate
      mid5: full_adder port map(T1(p+7),T2(p+3),T3(p),EX2(p+2),EX1(p+8));
    end generate F4;
    F5: half_adder port map(T2(10),T3(7),EX2(9),EX1(15));
      
    end layer4_arch;
    
--------------------------final reduction layer-------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity final_layer is
  port(EX1:in std_logic_vector(15 downto 0);
       EX2:in std_logic_vector(9 downto 0);
       Prod:out std_logic_vector(16 downto 0));
     end final_layer;
     
architecture final_layer_arch of final_layer is
    
    component half_adder is
      PORT (A,B: in std_logic;
            S,Cout: out std_logic);
    end component;
    
     component full_adder is
      PORT (A,B,Cin: in std_logic;
            S,Cout: out std_logic);
    end component;
   
   signal tmp:std_logic_vector(9 downto 0); 
    begin
      
  G0:Prod(0)<=EX1(0);
     Prod(1)<=EX1(1);
     Prod(2)<=EX1(2);
     Prod(3)<=EX1(3);
     Prod(4)<=EX1(4);
  --ripple carry adder
  G1: full_adder port map (EX1(5),EX2(0),'0',Prod(5),tmp(0));
  G2:for q in 0 to 8 generate
    mid6: full_adder port map (EX1(q+6),EX2(q+1),tmp(q),Prod(q+6),tmp(q+1));
    end generate G2;
  --end of ripple carry adder
  G3:half_adder port map (EX1(15),tmp(9),Prod(15),Prod(16));
    
  end final_layer_arch; 
  
  -------------------8bit wallace multiplier tree------------------
  library ieee;
    use ieee.std_logic_1164.all;
  
  entity wallace is
    PORT (A,B: in std_logic_vector(7 downto 0);
          Pr: out std_logic_vector(16 downto 0)); 
  end wallace;
  
  architecture my_wallace of wallace is
  
  component prod_gen is
    PORT (A,B: in std_logic_vector(7 downto 0);
          PP1,PP2,PP3,PP4,PP5,PP6,PP7,PP8: out std_logic_vector(7 downto 0));
  end component;
  
  component layer1 is
    PORT( PP1,PP2,PP3,PP4,PP5,PP6: in std_logic_vector (7 downto 0);
          L1,L3:out std_logic_vector(9 downto 0);
          L2,L4: out std_logic_vector(7 downto 0));
  end component;
  
  component layer2 is
    PORT( F1,F3: in std_logic_vector (9 downto 0);
          F2,F4,F5,F6:in std_logic_vector(7 downto 0);
          SE1:out std_logic_vector(10 downto 0);
          SE2,SE3:out std_logic_vector(9 downto 0);
          SE4:out std_logic_vector(7 downto 0));
  end component;
  
  component layer3 is
    PORT( SE1:in std_logic_vector(10 downto 0);
          SE2,SE3:in std_logic_vector(9 downto 0);
          T1:out std_logic_vector(13 downto 0);
          T2:out std_logic_vector(10 downto 0));
  end component;
  
  component layer4 is
    PORT( T1: in std_logic_vector(13 downto 0);
          T2: in std_logic_vector(10 downto 0);
          T3: in std_logic_vector(7 downto 0);
          EX1:out std_logic_vector(15 downto 0);
          EX2:out std_logic_vector(9 downto 0));
  end component;
  
  component final_layer is
  port(EX1:in std_logic_vector(15 downto 0);
       EX2:in std_logic_vector(9 downto 0);
       Prod:out std_logic_vector(16 downto 0));
     end component;
      
    signal buffer1,buffer2,buffer3,buffer4: std_logic_vector (7 downto 0);
    signal buffer5,buffer6,buffer7,buffer8: std_logic_vector (7 downto 0);
    signal FL1,FL3,SL2,SL3,FF2: std_logic_vector(9 downto 0);
    signal FL2,FL4,SL4: std_logic_vector(7 downto 0);
    signal SL1,TL2:std_logic_vector(10 downto 0);
    signal TL1:std_logic_vector(13 downto 0);
    signal FF1:std_logic_vector(15 downto 0);   
    
  begin
    
    W0: prod_gen port map (A,B,buffer1,buffer2,buffer3,buffer4,buffer5,buffer6,buffer7,buffer8);
    W1: layer1 port map (buffer1,buffer2,buffer3,buffer4,buffer5,buffer6,FL1,FL3,FL2,FL4);
    W2: layer2 port map(FL1,FL3,FL2,FL4,buffer7,buffer8,SL1,SL2,SL3,SL4);
    W3: layer3 port map(SL1,SL2,SL3,TL1,TL2);
    W4: layer4 port map(TL1,TL2,SL4,FF1,FF2);
    W5: final_layer port map(FF1,FF2,Pr);
    
  end my_wallace;