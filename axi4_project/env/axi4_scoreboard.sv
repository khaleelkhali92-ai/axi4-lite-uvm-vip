`uvm_analysis_imp_decl(_mon)

class axi4_lite_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi4_lite_scoreboard)

    uvm_analysis_imp_mon #(axi4_lite_transaction, axi4_lite_scoreboard) analysis_export;

    bit [31:0] ref_mem [0:1023];
    
    int total_write, total_read, pass_count, fail_count;

    axi4_lite_transaction cov_tr; 

    covergroup axi_cov;
        option.per_instance = 1;

        // Cover Read vs Write
        CP_TRANS_TYPE: coverpoint cov_tr.is_write {
            bins READ  = {0};
            bins WRITE = {1};
        }

        // Cover Address Ranges (Prove you hit low, mid, and high addresses)
        CP_ADDR: coverpoint cov_tr.addr {
            bins LOW_ADDR  = {[12'h000 : 12'h3FF]};
            bins MID_ADDR  = {[12'h400 : 12'h7FF]};
            bins HIGH_ADDR = {[12'h800 : 12'hBFF]};
            bins MAX_ADDR  = {[12'hC00 : 12'hFFF]};
        }

        // Cover Unaligned Addresses (Important for AXI SLVERR generation)
        CP_ALIGNMENT: coverpoint cov_tr.addr[1:0] {
            bins ALIGNED   = {2'b00};
            bins UNALIGNED = {2'b01, 2'b10, 2'b11};
        }

        // Cover Write Strobes 
        CP_WSTRB: coverpoint cov_tr.wstrb {
            bins ALL_ZEROS = {4'b0000};
            bins BYTE0     = {4'b0001};
            bins BYTE1     = {4'b0010};
            bins BYTE2     = {4'b0100};
            bins BYTE3     = {4'b1000};
            bins ALL_ONES  = {4'b1111};
            bins OTHERS    = default; // Captures partial strobes like 4'b0011
        }

        // Cover Write Responses (BRESP)
        CP_BRESP: coverpoint cov_tr.bresp {
            bins OKAY   = {2'b00};
           // bins EXOKAY = {2'b01};
            bins SLVERR = {2'b10};
           // bins DECERR = {2'b11};
        }

        // Cover Read Responses (RRESP)
        CP_RRESP: coverpoint cov_tr.rresp {
            bins OKAY   = {2'b00};
           // bins EXOKAY = {2'b01};
            bins SLVERR = {2'b10};
           // bins DECERR = {2'b11};
        }

        // CROSS COVERAGE: Prove we saw errors on BOTH reads and writes
        CROSS_TYPE_x_BRESP: cross CP_TRANS_TYPE, CP_BRESP {

            ignore_bins read_bresp = binsof(CP_TRANS_TYPE.READ);
        }
        
        CROSS_TYPE_x_RRESP: cross CP_TRANS_TYPE, CP_RRESP {

            ignore_bins write_rresp = binsof(CP_TRANS_TYPE.WRITE);
        }

    endgroup


    function new(string name="axi4_lite_scoreboard", uvm_component parent=null);
        super.new(name,parent);
        analysis_export = new("analysis_export",this);
        axi_cov = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        foreach(ref_mem[i]) ref_mem[i] = '0;
        total_write = 0; total_read = 0; pass_count = 0; fail_count = 0;
    endfunction

  
    function void write_mon(axi4_lite_transaction tr);
        int addr = tr.addr[11:2];

        cov_tr = tr; 
        axi_cov.sample();

        // 2. CHECKING LOGIC
        if (addr > 1023) begin
            `uvm_error(get_type_name(), $sformatf("Invalid Address: %0h", tr.addr))
            return;
        end
        
        if (tr.is_write) begin
            total_write++;

            // Handle Unaligned Address (Expecting SLVERR)
            if (tr.addr[1:0] != 2'b00) begin
                if (tr.bresp == 2'b10) begin
                    `uvm_info("SCOREBOARD", $sformatf("SLVERR PASS Addr=%0h BRESP=%0b", tr.addr, tr.bresp), UVM_MEDIUM)
                end else begin
                    `uvm_error("SCOREBOARD", $sformatf("Expected SLVERR but got BRESP=%0b Addr=%0h", tr.bresp, tr.addr))
                end
            end 
            // Handle Valid Write
            else begin
                if(tr.bresp != 2'b00)
                    `uvm_error("SCOREBOARD", $sformatf("Unexpected BRESP=%0b Addr=%0h", tr.bresp, tr.addr))

                if(tr.wstrb[0]) ref_mem[addr][7:0]   = tr.wdata[7:0];
                if(tr.wstrb[1]) ref_mem[addr][15:8]  = tr.wdata[15:8];
                if(tr.wstrb[2]) ref_mem[addr][23:16] = tr.wdata[23:16];
                if(tr.wstrb[3]) ref_mem[addr][31:24] = tr.wdata[31:24];

                `uvm_info(get_type_name(), $sformatf("WRITE PASS Addr=%0h Data=%08h", tr.addr, tr.wdata), UVM_MEDIUM)
            end
        end 
        else begin
            total_read++;

            if(tr.rresp != 2'b00)
                `uvm_error("SCOREBOARD", $sformatf("Unexpected RRESP = %0d", tr.rresp))

            if(ref_mem[addr] === tr.rdata) begin
                pass_count++;
                `uvm_info(get_type_name(), $sformatf("READ PASS Addr=%0h Expected=%08h Actual=%08h", tr.addr, ref_mem[addr], tr.rdata), UVM_LOW)
            end else begin
                fail_count++;
                `uvm_error(get_type_name(), $sformatf("READ FAIL Addr=%0h Expected=%08h Actual=%08h", tr.addr, ref_mem[addr], tr.rdata))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("\n======================================");
        $display("AXI4-Lite Scoreboard Summary");
        $display("======================================");
        $display("Total Writes : %0d", total_write);
        $display("Total Reads  : %0d", total_read);
        $display("PASS         : %0d", pass_count);
        $display("FAIL         : %0d", fail_count);
        $display("Coverage     : %0.2f%%", axi_cov.get_coverage());
        $display("======================================\n");
    endfunction

endclass