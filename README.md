# UART Protocol Implementation on Nexys A7 FPGA 🎉🔌

As a team[Hemanth](https://github.com/hemanth028), [Naveen Kumar](https://github.com/naveen20306), [Sabarish Mohan](https://github.com/sabarishmohanjs), we have designed and implemented a fully functional UART communication system between two **Nexys A7 100T FPGA boards**, using custom Verilog code. This project covers the complete UART protocol, including start bits, stop bits, parity bit, and robust metastability handling.

---

## 🚀 Project Overview

Our implementation enables reliable serial communication between two FPGA boards by following the UART standard with enhancements for stability and error detection. Key features include:

- Custom-designed transmitter and receiver modules in Verilog
- Inclusion of **start bit**, **stop bit**, and **parity bit** handling for error checking
- Implementation of **metastability handling** techniques to ensure signal integrity between clock domains
- Real hardware communication between two independent Nexys A7 boards

---

## 🎯 Key Features & Highlights

- **Full Duplex UART Communication** between two FPGA boards  
- **Custom Verilog HDL** modules for transmitter and receiver  
- Incorporation of **start/stop bits** ensuring proper framing of data  
- **Parity bit generation and checking** for error detection  
- **Metastability handling** to tackle asynchronous signal issues  
- Comprehensive **testbenches and simulations** verifying functionality  
- Compatible with **Nexys A7 100T** hardware and Vivado toolchain  
- Detailed **documentation and demo videos** for better understanding  

---

## 🗂 Repository Structure

```
UART-protocol-implementation-using-FPGA
├── 📹 Demo-Video/
│ └── Hardware demonstration of UART communication between two Nexys A7 boards
├── 🧪 Simulation-Files/
│ └── Verilog simulation files containing transmitter, receiver, ascii_to_7seg and uart_top_module modules.
├── 🧰 testbench/
│ └── Testbench files for functional verification of UART modules
├── ⚙️ nexys-a7-100t-xdc-file/
│ └── Pin constraints and board configuration files for Nexys A7 100T FPGA
├── 📄 uart-report/
│ └── Project report
├── README.md
```


---

## 🛠 Technologies & Tools Used

- **FPGA Development Board:** Digilent Nexys A7 100T (XC7A100T) 
- **Hardware Description Language:** Verilog HDL  
- **Development Environment:** Xilinx Vivado Design Suite (Synthesis, Implementation, Simulation)  
- **Simulation Tools:** Vivado Simulator for functional verification  
- **Metastability Handling:** Synchronizer flip-flops and timing constraints  

---


## 🚦 How to Use This Repository

1. Explore the **simulation-file** and **testbench** folders to understand and verify UART behavior on simulation tools.  
2. Use the **nexys-a7-100t-xdc-file** folder for pin constraints to set up the FPGA hardware environment.  
3. Watch the **demo-video** to see the real hardware UART communication in action between two boards.  
4. Refer to the detailed **uart-report** for architecture, design decisions, and implementation insights.  
5. Modify and extend the Verilog modules to experiment with the UART design and learn more about FPGA communication protocols.  

---

## 📄 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute this project, with appropriate credit to the authors.

---

## 🤝 Contribution

Contributions from the community are welcome! Feel free to submit issues or pull requests to improve functionality, add features, or enhance documentation.

---



Thank you for exploring our UART protocol implementation on Nexys A7 FPGA boards! 🚀✨  
Happy coding and hardware hacking!



