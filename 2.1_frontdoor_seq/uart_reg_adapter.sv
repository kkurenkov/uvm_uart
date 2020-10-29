`ifndef INC_UART_REG_ADAPTER
`define INC_UART_REG_ADAPTER


class uart_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(uart_reg_adapter)
  int tx_addr;
  int tx_data;

  bit second_step = 0 ;
  bit first_step = 0;
  
  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_reg_adapter");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // function reg2bus
  // ----------------------------------------------------------------------------

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  // instead of this function 
  // use uart_reg_frontdoor_seq.
  // which contains 3 transaction
  // 1 transaction - write(0x1)/read(0x1).
  // 2 transaction - address.
  // 3 transaction - data.
  endfunction

  // ----------------------------------------------------------------------------
  // function bus2reg
  // ----------------------------------------------------------------------------

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    uart_item uart_item_reg;

    if(!$cast(uart_item_reg, bus_item))
    `uvm_fatal(get_name(), "$cast is failed")
    
    rw.status = UVM_NOT_OK;
    case ({first_step,second_step})
      2'b11: begin
        rw.data = uart_item_reg.data;
        rw.status = UVM_IS_OK;
        rw.addr = tx_addr;
        second_step = 0;
        first_step  = 0;
      end

      2'b10: begin
        tx_addr = uart_item_reg.data;
        second_step = 1;
      end

      default: begin
        if(uart_item_reg.data==1) begin // read transaction
          first_step = 1;
        end
      end
    endcase 

    if(rw.status != UVM_IS_OK) begin
      rw.addr = 'hFF;
      rw.data = 'h00;
      `uvm_info(get_full_name(),$sformatf("!!! !!! rw.data = %0h, rw.addr = %0h", rw.data, rw.addr), UVM_MEDIUM)
    end
  endfunction

endclass

`endif