
package FIFOCHECKER;

`timescale 1ns/10ps

import WRITINGAGENT::*;
import READINGAGENT::*;
import WRITINGMONITOR::*;

class FifoChecker
#(parameter DEPTH = 8, DATA_WIDTH = 12);
   local WritingAgent #(DEPTH, DATA_WIDTH) Wagent;
   local ReadingAgent #(DEPTH, DATA_WIDTH) Ragent;
   local WritingMonitor #(DEPTH, DATA_WIDTH) WMonitor;
   local int compare = 0;
   virtual FifoIf #(DEPTH, DATA_WIDTH) fifo;
   virtual MonitorIf Monitor;
   function new (virtual FifoIf #(DEPTH, DATA_WIDTH) fifo, virtual MonitorIf Monitor);
	this.fifo = fifo;
        this.Monitor = Monitor;
	this.Wagent = new(fifo);
	this.Ragent = new(fifo);
        this.WMonitor = new(fifo,Monitor);
   endfunction
   task Startenv();
	  Wagent.StartWAgent();
          Ragent.StartRAgent(Monitor);
	  #75ns;
          WMonitor.MonitorStart();
   endtask; 
   task EmptyFillCycle(int amount);
        repeat(amount) begin
	    Wagent.FillFifo();
	    Ragent.EmptyFifo();
        end
   endtask
   task setBurstRndDelay(int minBurst, maxBurst, minWaitCycle, maxWaitCycle);
        Wagent.setBurstRndDelay(minBurst, maxBurst, minWaitCycle, maxWaitCycle);
	Ragent.setBurstRndDelay(minBurst, maxBurst, minWaitCycle, maxWaitCycle);
   endtask
   task setDelay(int burstLength, waitCycle);
        Wagent.setDelay(burstLength, waitCycle);
        Ragent.setDelay(burstLength, waitCycle);
   endtask
   task SendValues(int amount, minBurst, maxBurst, minWaitCycle, maxWaitCycle);
	bit[DATA_WIDTH-1:0] data[];
        data = new[amount];
        for(int i = 0;i<amount; i++)
	    data[i] = $random;
        Wagent.setBurstRndDelay(minBurst, maxBurst, minWaitCycle, maxWaitCycle);
	Ragent.setBurstRndDelay(minBurst, maxBurst, minWaitCycle, maxWaitCycle);
        fork
	    Wagent.SendMultiple(data);
	    Ragent.ReadValues(amount);
 	join
   endtask
endclass
endpackage
