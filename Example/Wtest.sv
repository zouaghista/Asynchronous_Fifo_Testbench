
`timescale 1ns/10ps

import FIFOCHECKER::*;
import SCOREBOARD::*;

program wtest (FifoIf gf, MonitorIf Monitor);
   initial begin
       FifoChecker #(gf.DEPTH, gf.DATA_WIDTH) chk = new(gf, Monitor);
       ScoreBoard sc = new(Monitor);
       chk.Startenv();
       sc.Start();
       chk.setDelay(1,0);
       chk.EmptyFillCycle(100);
       chk.setBurstRndDelay(1,12,1,10);
       chk.EmptyFillCycle(100);
       repeat(500)
           chk.SendValues(180,1,15,1,10);
       sc.GetSummery();
   end
endprogram 