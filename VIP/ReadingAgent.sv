
package READINGAGENT;

class RAConfig;
  rand int    burstLength       = 0;
  rand int    waitCycle         = 0;
  local int   maxBurst          = 0;
  local int   minBurst          = 0;
  local int   maxWaitCycle      = 0;
  local int   minWaitCycle      = 0;
  constraint c_burst {
                        burstLength inside {[minBurst:maxBurst]};
                        waitCycle   inside {[minWaitCycle:maxWaitCycle]};
                     }
  function void setBurstRndDelay(int minBurst, maxBurst, minWaitCycle, maxWaitCycle);
    this.burstLength.rand_mode(1);
    this.waitCycle.rand_mode(1);
    this.maxBurst       = maxBurst;
    this.minBurst       = minBurst;
    this.maxWaitCycle   = maxWaitCycle;
    this.minWaitCycle   = minWaitCycle;
    this.genRndDelay();
  endfunction

  function void genRndDelay();
    assert (this.randomize())
    else $fatal(0, "WA_Cfg: Randomize failed");
  endfunction

  function void setDelay(int burstLength, waitCycle);
    this.burstLength.rand_mode(0);
    this.waitCycle.rand_mode(0);
    this.burstLength    = burstLength;
    this.waitCycle      = waitCycle;
  endfunction
endclass


class RADriver
#(parameter DEPTH = 8, DATA_WIDTH = 12);
  typedef bit[DATA_WIDTH-1:0] Databus;
  Databus ReadFifo[$];
  local RAConfig Cfg;
  local int BurstCount;
  virtual FifoIf #(DEPTH, DATA_WIDTH) fif;
  local int ReadCounter = 0;
  local virtual MonitorIf EmptyMonitor;
  task RunDriver(virtual MonitorIf Monitor);
    this.fif.fifo_enable = 1;
    fork
        this.RunLoop(Monitor);
    join_none
  endtask
  function new(virtual FifoIf #(DEPTH, DATA_WIDTH) fif, RAConfig Cfg);
     this.Cfg = Cfg;
     this.fif = fif;
  endfunction
  
  task WaitBusy();
     while(ReadCounter!=0)
	@(posedge fif.rd_clk);
  endtask
  task AddToReadCounter(int i);
     ReadCounter += i;
  endtask
  local task Delay(int amount);
     while(amount !=0) begin
       amount--;
       @(posedge fif.rd_clk);
     end
  endtask
  task RunLoop(virtual MonitorIf Monitor);
     if(Monitor == null)
	Monitor = EmptyMonitor;
     forever begin 
        @(posedge fif.rd_clk);
        if(ReadCounter!=0&&fif.fifo_empty==0&&fif.rd_rst_n==1) begin
	    ReadFifo.push_back(fif.rd_data);
            Monitor.out.data = fif.rd_data;
            Monitor.out.enable = 1;
            ReadCounter--;
            if(BurstCount==0) begin
               fif.rd_en = 0;
	       Monitor.out.enable = 0;
               Delay(Cfg.waitCycle);
               BurstCount = Cfg.burstLength;
            end else BurstCount--;
	    fif.rd_en = 1;
        end else begin fif.rd_en = 0;Monitor.out.enable = 0; end
        end
  endtask
endclass

class ReadingAgent
#(parameter DEPTH = 8, DATA_WIDTH = 12);
   local RADriver #(DEPTH, DATA_WIDTH) Driver;
   local RAConfig Cfg;
   virtual FifoIf #(DEPTH, DATA_WIDTH) fif;
   bit Rstarted = 0;
   function new(virtual FifoIf #(DEPTH, DATA_WIDTH) fif);
     this.Cfg = new();
     this.fif = fif;
     this.Driver = new(this.fif, this.Cfg);
   endfunction 
   task StartRAgent(virtual MonitorIf Monitor = null);
      if(!Rstarted) begin
         fork
            this.Driver.RunDriver(Monitor);
         join_none
      end
   endtask
   task EmptyFifo();
        ReadValues(this.DEPTH);
   endtask
   task ReadValues(int i);
 	this.Driver.AddToReadCounter(i);
	this.Driver.WaitBusy();
   endtask

   function void setBurstRndDelay(int minBurst, maxBurst, minWaitCycle, maxWaitCycle);
      this.Cfg.setBurstRndDelay(minBurst, maxBurst, minWaitCycle, maxWaitCycle);
   endfunction

  function void genRndDelay();
      this.Cfg.genRndDelay();
  endfunction
 
  function void setDelay(int burstLength, waitCycle);
      this.Cfg.setDelay(burstLength, waitCycle);
  endfunction
endclass
endpackage