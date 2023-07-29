package WRITINGMONITOR;

import WRITINGAGENT::*;

class WritingMonitor
#(parameter DEPTH = 8, DATA_WIDTH = 12);
   virtual FifoIf #(DEPTH,DATA_WIDTH) fif;
   virtual MonitorIf Monitor;
   function new(virtual FifoIf #(DEPTH,DATA_WIDTH) fif, virtual MonitorIf Monitor);
	this.fif = fif;
        this.Monitor = Monitor;
   endfunction
   task MonitorStart();
   fork
     forever begin
        @(posedge fif.wr_clk)
	if(fif.wr_en==1) begin
	    Monitor.in.data = fif.wr_data;
	    Monitor.in.enable = 1;
	end else Monitor.in.enable = 0;
     end
   join_none
   endtask

endclass
endpackage