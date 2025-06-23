# sha-256_HW_accelerator
Hardware-accelerated SHA-256 implemented on a PYNQ-Z2 FPGA. Includes custom SystemVerilog IP, AXI4-Lite/DMA integration, and Python/Jupyter interface. Achieves faster hashing for large data vs CPU


**🔐 SHA-256 Hardware Accelerator on PYNQ**

This repository contains the full implementation and documentation of a hardware-accelerated SHA-256 hashing engine developed as a final university project.

The project leverages the Xilinx PYNQ-Z2 FPGA platform to accelerate cryptographic hashing using a custom SystemVerilog IP core connected via AXI4-Lite and AXI-Stream DMA. The host interface is implemented in Python using Jupyter Notebook, enabling interactive hashing, benchmarking, and result validation.


**🚀 Features**

Full RTL implementation of SHA-256 per FIPS PUB 180-4
Custom SystemVerilog IP optimized for pipelined hashing
AXI4-Lite + AXI-Stream DMA for high-throughput communication
Python interface running on PYNQ’s ARM cores for easy control and testing
Performance comparison vs software hashing to show hardware advantage on large datasets
Includes simulation, testbenches, waveform analysis, and full documentation


**📦 Contents**

rtl/ – SystemVerilog source for the SHA-256 core and wrapper

vivado/ – Block design files and bitstream generation scripts

notebooks/ – Python Jupyter notebooks for usage, testing, and benchmarking

report/ – Full project book in Hebrew describing the theory, design, implementation, and results


**📊 Result Highlights**

Hardware beats software in performance for inputs ≥ 70KB

~2.6× speedup over CPU at 14MB input size

Demonstrates how FPGAs can effectively offload compute-heavy cryptographic tasks


**🛠 Requirements**
* Vivado 2019.1
* PYNQ-Z2 board
* Python 3.x with PYNQ image
* Jupyter Notebook
