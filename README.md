# Asynchronous_Fifo_Testbench
Asynchronous fifos are vital components used mainly in transferring data from different clock domains, offering asynchronous write and read operations driven by two different clocks.
## Introduction
This project is a testbench written in *system verilog* for evaluating the behavior of such fifos. The structure is simple and easy to modify if more specific tests are required.
## Content
### Section 1: VIP
The *VIP* (verification IP) folder contains 2 interfaces and 5 classes.

**Intrfaces:** 

Both the monitoring and fifo interfaces work as a linker between the actual testbench and your RTL code, making it possible to monitor and interact with the fifo.

**Classes:** 
* Two agents are actively providing read and write operations to the fifo to stimulate it.
* A checker class that incapsulates both of the agents, providing higher abstraction and easier test writing.
* A monitor class to fetch the transactions and feed them into the scoreboard.
* A scoreboard to evaluate and check for errors.

**General relationship between classes**

![Class Model](https://github.com/zouaghista/Asynchronous_Fifo_Testbench/assets/59181866/7c3c38d9-a863-4046-a505-82a47e7c4ad2)

### Section 2: Testbench
The *Example* folder contains 3 main files.
* *TestBench*: Serves as the main point of linkage between the test bench and the fifo module, where everything is initialized and the clocks are defined.
* *TestBenchTop*: The starting point of the simulation, starts different testBenches with different settings.
* *Wtest*: Drives the agents and performs the test. 

**Preview of the Wtest:**
![355159644_154882567608590_5116117783396929569_n](https://github.com/zouaghista/Asynchronous_Fifo_Testbench/assets/59181866/577d0d4c-9c6b-42fe-a5be-48cc5c970443)

## How to use
Simply go to Example/Testbench, and change the commented module initialization with your own and adjust the interface wiring accordingly, This project *does not come with an RTL code for the fifo* **you must provide your own**.
You can then compile the file_list.f file and simulate the *testBenchTop*
> Vlog -f file_list.f
