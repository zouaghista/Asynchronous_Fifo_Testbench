
package WRITINGAGENT;

class WAConfig;
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


class WADriver
#(parameter DEPTH = 8, DATA_WIDTH = 12);
   
  typedef bit[DATA_WIDTH-1:0] Databus;
  local Databus SendFifo[$];
  local WAConfig Cfg;
  local int BurstCount;
  virtual FifoIf #(DEPTH, DATA_WIDTH) fif;
  task RunDriver();
    fork
        this.RunLoop();
    join_none
  endtask
  function new(virtual FifoIf #(DEPTH, DATA_WIDTH) fif, WAConfig Cfg);
     this.Cfg = Cfg;
     this.fif = fif;  
  endfunction

  function FifoEmpty();
     return SendFifo.size() == 0;
  endfunction

  task WaitTillEmpty();
     while(!FifoEmpty())
         @(posedge fif.wr_clk);
  endtask

  task AddToFifo(Databus Addition[$]);
     foreach (Addition[i])
         SendFifo.push_back(Addition[i]);
  endtask
  task EmptyFifo();
     SendFifo = {};
  endtask;
  local task Delay(int amount);
     while(amount !=0) begin
       amount--;
       @(posedge fif.wr_clk);
     end
  endtask
  task RunLoop();
     forever begin 
        @(posedge fif.wr_clk);
        if(fif.wr_line_en == 1) begin
            SendFifo.pop_front();
            if(BurstCount==0) begin
               fif.wr_line_en = 0;
	       fif.wr_en = 0;
               Delay(Cfg.waitCycle);
               BurstCount = Cfg.burstLength;
            end else BurstCount--;
        end
        if(!fif.fifo_full&&!FifoEmpty()&&fif.wr_rst_n) begin
            fif.wr_line_en = 1;
	    fif.wr_en = 1;
            fif.wr_data = SendFifo[0];
        end else begin  fif.wr_line_en = 0;
			fif.wr_en = 0; end
        end
  endtask
endclass

class WritingAgent
#(parameter DEPTH = 8, DATA_WIDTH = 12);
   
   typedef bit[DATA_WIDTH-1:0] Databus;
   local WADriver #(DEPTH, DATA_WIDTH) Driver;
   local WAConfig Cfg;
   local bit Wstarted;
   local virtual FifoIf #(DEPTH, DATA_WIDTH) fif;
   function new(virtual FifoIf #(DEPTH, DATA_WIDTH) fif);
     this.Cfg = new();
     this.fif = fif;
     this.Driver = new(this.fif, this.Cfg);
     Wstarted = 0;
   endfunction 
   task StartWAgent();
       if(!Wstarted)
       begin
          Wstarted = 1;
          fork
             this.Driver.RunDriver();
          join_none
        end
   endtask
   task SendSingle(Databus Data);
      Databus newdata[$] = {Data};
      Driver.AddToFifo(newdata);
      Driver.WaitTillEmpty();
   endtask

   task SendMultiple(Databus data[]);
      Databus newdata[$] = {data};
      Driver.AddToFifo(newdata);
      Driver.WaitTillEmpty();
   endtask
   task FillFifo();
      Databus data[] = new[this.fif.DEPTH];
      for(int i = 0; i<this.DEPTH;i++) begin
      	   data[i] = $random;
      end
      SendMultiple(data);
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
