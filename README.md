# AXI4-Lite UVM Verification Environment

A complete, industry-standard Universal Verification Methodology (UVM) testbench for an AXI4-Lite Slave interface. 

## Overview
This project verifies an AXI4-Lite memory-mapped slave using a custom UVM environment. The testbench is designed to validate standard read/write operations, byte-lane strobing (WSTRB), and error response handling (SLVERR).

## Architecture Highlights

<img width="599" height="327" alt="image" src="https://github.com/user-attachments/assets/8629a54d-597e-41c8-9067-bcf2e655cfa5" />


* **Active/Passive Agent:** Configurable AXI4-Lite driver and monitor.
* **Transaction-Level Modeling:** Unified read/write transaction class optimized for simulation performance.
* **Automated Checking:** Scoreboard implements a reference memory model and validates hardware responses (BRESP/RRESP) dynamically.
* **Comprehensive Coverage:** Functional coverage model utilizing SystemVerilog `covergroup` and `cross` coverage to prove 100% state traversal without relying on procedural dummy variables.

## Verification Features Tested
- [x] Full Address Map Traversal (Low, Mid, High, Max bins)
- [x] Write Strobe (`WSTRB`) alignment (Byte, Half-Word, Word)
- [x] Write Error generation and checking (`SLVERR` on unaligned addresses)
- [x] Read Error generation and checking
- [x] Back-to-back Read/Write sequences

## Coverage Results
The test suite achieves **100.00% Functional Coverage** across transaction types, address ranges, and response combinations.

```text
======================================
AXI4-Lite Scoreboard Summary
======================================
Total Writes : 58
Total Reads  : 51
PASS         : 51
FAIL         : 0
Coverage     : 100.00%
======================================
