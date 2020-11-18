`ifndef INC_HIGH_REG_ITEM
`define INC_HIGH_REG_ITEM

class high_reg_item extends uvm_sequence_item;
  function new(string name = "high_reg_item");
    super.new(name);
  endfunction

  rand bit [7:0]  kind;
  rand bit [7:0]  addr;
  rand bit [7:0]  data;

  `uvm_object_utils_begin(high_reg_item)
    `uvm_field_int (kind, UVM_DEFAULT)
    `uvm_field_int (addr,  UVM_DEFAULT)
    `uvm_field_int (data, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

typedef uvm_sequencer #(high_reg_item) High_reg_sequencer;

//---------------------------------------------------------------------------
//
// Class: high_reg2uart_seq
//
// 1-to-many : each High reg item results in N UART items
//
//---------------------------------------------------------------------------

class high_reg2uart_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(high_reg2uart_seq)

  function new(string name="");
    super.new(name);
  endfunction

  uvm_sequencer #(high_reg_item) up_sequencer;

 virtual task body();
    high_reg_item reg_transaction;
    uart_item req;
    uart_item uart_rsp;

    forever begin
      up_sequencer.get_next_item(reg_transaction);
        case (reg_transaction.kind)
          UVM_WRITE: begin
            `uvm_create(req)
                  rand_RX_TX: assert(req.randomize()
                      with {
                      req.start_bit == 0;
                      req.data == reg_transaction.kind;
                      req.parity_bit == ^reg_transaction.kind;
                      req.end_bit == 1;
                      req.direction == 1;
                    })
                    else
                      `uvm_fatal(get_full_name(), "Randomization failed!")
                `uvm_send(req)

            `uvm_create(req)
                  rand_addr: assert(req.randomize()
                      with {
                      req.start_bit == 0;
                      req.data == reg_transaction.addr;
                      req.parity_bit == ^reg_transaction.addr;
                      req.end_bit == 1;
                      req.direction == 1;
                    })
                    else
                      `uvm_fatal(get_full_name(), "Randomization failed!")
                `uvm_send(req)

            `uvm_create(req)
                rand_data: assert(req.randomize()
                    with {
                    req.start_bit == 0;
                    req.data == reg_transaction.data;
                    req.parity_bit == ^reg_transaction.data;
                    req.end_bit == 1;
                    req.direction == 1;
                  })
                  else
                    `uvm_fatal(get_full_name(), "Randomization failed!")
              `uvm_send(req)
          end
        endcase
      up_sequencer.item_done();
    end
  endtask

endclass


class uart_2_high_monitor extends  uvm_subscriber #(uart_item);
  `uvm_component_utils(uart_2_high_monitor)

  uvm_analysis_port#(high_reg_item) item_collected_port;

  high_reg_item high_transaction_out_rx;
  high_reg_item high_transaction_out_tx;
  int counter_uart_item_rx = 0;
  int counter_uart_item_tx = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port",this);
  endfunction

  function void write(uart_item t);
    if(t.direction) begin
      case (counter_uart_item_tx)
        0: begin
          high_transaction_out_tx = high_reg_item::type_id::create("high_transaction_out_tx", this);
          counter_uart_item_tx = 1;
          high_transaction_out_tx.kind = UVM_WRITE;
        end
        1: begin
          counter_uart_item_tx = 2;
          high_transaction_out_tx.addr = t.data;
        end
        2: begin
          counter_uart_item_tx = 0;
          high_transaction_out_tx.data = t.data;
          `uvm_info("TX",{"transceive ", $sformatf(" kind = %0d, addr = %0h, data = %0h", high_transaction_out_tx.kind, high_transaction_out_tx.addr, high_transaction_out_tx.data)}, UVM_MEDIUM)
        end
        default : counter_uart_item_tx = 0;
      endcase
    end 
    else begin
      case (counter_uart_item_rx)
        0: begin
          high_transaction_out_rx = high_reg_item::type_id::create("high_transaction_out_rx", this);
          counter_uart_item_rx = 1;
          high_transaction_out_rx.kind = UVM_READ;
        end
        1: begin
          counter_uart_item_rx = 2;
          high_transaction_out_rx.addr = t.data;
        end
        2: begin
          counter_uart_item_rx = 0;
          high_transaction_out_rx.data = t.data;
          `uvm_info("RX",{"receive ", $sformatf(" kind = %0d, addr = %0h, data = %0h", high_transaction_out_rx.kind, high_transaction_out_rx.addr, high_transaction_out_rx.data)}, UVM_MEDIUM)
        end
        default : counter_uart_item_rx = 0;
      endcase
    end
  endfunction

endclass


class high_reg_uart_layering extends uvm_subscriber #(uart_item);
  `uvm_component_utils(high_reg_uart_layering)
  uvm_analysis_port #(high_reg_item) item_collected_port;
  High_reg_sequencer high_reg_sequencer;
  uart_2_high_monitor uart_2_high_mon;
  uart_agent uart_ag;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    high_reg_sequencer = High_reg_sequencer::type_id::create("high_reg_sequencer",this);
    uart_2_high_mon = uart_2_high_monitor::type_id::create("uart_2_high_mon",this);
    item_collected_port = new("item_collected_port" , this );
  endfunction

  function void connect_phase(uvm_phase phase);
    uart_2_high_mon.item_collected_port.connect( item_collected_port );
  endfunction

  virtual task run_phase(uvm_phase phase);
    high_reg2uart_seq reg2uart_seq;

    reg2uart_seq = high_reg2uart_seq::type_id::create("reg2uart_seq");

    // connect translation sequences to their respective upstream sequencers
    reg2uart_seq.up_sequencer = high_reg_sequencer;

    // start the translation sequences
    fork
      reg2uart_seq.start(uart_ag.sequencer);
    join_none
  endtask

  // this method connects the incoming C_items to the c2b monitor
  function void write(uart_item t);
    uart_2_high_mon.write(t);
  endfunction

  // a convenience method to connect active and passive datapaths in one method
  function void uart_connect_to_agent( uart_agent agent );
    uart_ag = agent;
    uart_ag.monitor.item_collected_port.connect(analysis_export);
  endfunction

endclass

`endif
