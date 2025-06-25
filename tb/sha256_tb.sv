`timescale 1ns / 1ns
module sha256_tb;
/*
  test cases:
  test 1 - NULL
  test 2 - abc
  test 3 - abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq
  test 4 - rewqiuytsapohgfd;lkjcxz'mbnvf/.,nbedxvium,aw5duinuerfxsbvbastyxmoiuytrewgfdslkjh,mnbvcxzxzaqwsxcedcvrfvbtgbnyhnmujm,rewqiuytsapohgfd;lkjcxz'mbnvf/.,
  test 5 - 88866d5a04c2b81f579962b7293928a6a2458381ef4f022fc2ec7a72422b275e0f5588e36c63f371a4ddd72d89308a6d1a41e5edced3f805720ecea64f09d21b1059ff90b5b1f5e9ff7f3374da3ded1d47eb9f6562d0bff48974c0234e5be5fa1f571c984c5d4dc8edbd13d4fffc20b5009578b782b7f6b029d1b1b4c7726ef8870d1b9130d967e6b170352e3c1d04579ad3f1207efca01c6d0d4416329e118a66fb0974bac9a026e5511650a4a2a1c10264cf24c38d0c66f3cf3102e2c5be3e69ffd24fcf964f94dcc329543f8be0b67d3ec91547a61ce928ff1e2d1072c1ab9b499dda9a37847747d0011f6457f03dafdce9e23ea6bbbf4371eae2b4278f914ac099c428bdac62d9e0e28a8c97dfd9942a26bb9323b199787ec001a4fc7d8cda3db0928947ddaa9c73dd1a5a496d6e86adaca8ef5b071bda3269f9a31629d8
  test 6 - d364e8f1545ce324431f92858db5d670dbb90c597149fd94402fbef07d04a3f76e5604c98102eec5adb391582c6758b85ddd03f53b1696b125c71235cf692dd45f260dd4fe1e19759544655511310ce88581166caa512601073ddceaa9a0d3608952ecd51bf2a12ed18ad3d8a246c2098d97d8dc762483c49ce8e1ccb4c7ff8721b765046af02a3b44fa8a4ffb474e3c8dfc121c7a4fcf5cf597b269b8465ed838be2884645a504f251846bd82e8ccdcc7f4296b6995d44fd2b3634322c119a11abdcff594756536f1d217d65dfcc6e48dfe4976865425f17f95f9b420368ea99df22598c33f49b0a9f669485e5661682d698fc973c0e1b4627d53fe417e82be13243d29ef5c950f56cb298cedbffac5899ca76c4e785cf683468eb897aca16e0438df074093b0e177e94d707ebece79fe133407a7f48756c5d112f3de2ff50e
  test 7 - ...
*/
  logic clk = 0;
  logic resetn;
  logic start_i;
  logic s_axis_tlast;
  logic s_axis_tvalid;
  logic [31:0] s_axis_tdata;
  logic m_axis_tready;
  logic [31:0] m_axis_tdata;
  logic s_axis_tready, m_axis_tvalid;
  logic m_axis_tlast;
  logic delayed;
  logic [255:0]compression;
  logic [63:0] data[130];
  logic [63:0] key[16];
  typedef enum {test_1,test_2,test_3,test_4,test_5,test_6,test_7} test;
  test t;
  string test_str, input_massage;

  sha256_main uut ( .clk(clk),
                    .resetn(resetn),
                    .s_axis_tlast(s_axis_tlast),
                    .s_axis_tvalid(s_axis_tvalid),
                    .s_axis_tdata(s_axis_tdata),
                    .m_axis_tready(m_axis_tready), // m_axis_tready
                    .m_axis_tdata(m_axis_tdata),
                    .s_axis_tready(s_axis_tready),
                    .m_axis_tvalid(m_axis_tvalid),
                    .m_axis_tlast(m_axis_tlast) );
  initial forever #5 clk = ~clk;
 task automatic SendBlockData (input [3:0]block_amount);
    int unsigned j = 0;
    do begin
      @(posedge clk) begin
      #1;
        start_i = j == 0;
        s_axis_tvalid = 1'b1;
        s_axis_tdata = data[j];
        if (j == block_amount*16-1) s_axis_tlast <= 1'b1;
        else s_axis_tlast <= 1'b0;
      end
      if (s_axis_tvalid && s_axis_tready) j++;
    end while (j < block_amount*16);
    @(posedge clk) begin
      #1
      s_axis_tlast <= 1'b0;
      s_axis_tvalid <= 1'b0;
      j = 0;
    end
    wait (m_axis_tvalid);
      $display(test_str, "input massage: %h", input_massage);
      $display("Hash Output: ");
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
       do @(posedge clk); while (!m_axis_tready&&m_axis_tvalid); $display("%h", m_axis_tdata);
      $display("---expected: %h", compression);
      #100;
  endtask
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   task automatic test_vec_1();
    test_str = "test 1-"; t = test_1;
    input_massage = "NULL";
    data = '{default: '0};
    data[0] = 32'h80000000;
    compression = 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
  endtask
  
  task automatic test_vec_2();
  test_str = "test 2-"; t = test_2;
  input_massage = "abc";
    data = '{default: '0};
    data[0] = 32'h61626380;
    data[15] = 32'h00000018;
    compression = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;
  #1; endtask

  task automatic test_vec_3();
  test_str = "test 3-"; t = test_3;
    input_massage = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
      data = '{default: '0};
      data[0:14] = {'h61626364, 'h62636465, 'h63646566, 'h64656667,
                    'h65666768, 'h66676869, 'h6768696A, 'h68696A6B,
                    'h696A6B6C, 'h6A6B6C6D, 'h6B6C6D6E, 'h6C6D6E6F,
                    'h6D6E6F70, 'h6E6F7071, 'h80000000};
      data[31] = 'h000001c0;
      compression = 256'h248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1;
  #1; endtask
  
  task automatic test_vec_4();
  test_str = "test 4-"; t = test_4;
  input_massage ="rewqiuytsapohgfd;lkjcxz'mbnvf/.,nbedxvium,aw5duinuerfxsbvbastyxmoiuytrewgfdslkjh,mnbvcxzxzaqwsxcedcvrfvbtgbnyhnmujm,rewqiuytsapohgfd;lkjcxz'mbnvf/.,";
    data = '{default: '0};
    data[0:37] = {'h72657771,    'h69757974,    'h7361706f,    'h68676664,
                  'h3b6c6b6a,    'h63787a27,    'h6d626e76,    'h662f2e2c,
                  'h6e626564,    'h78766975,    'h6d2c6177,    'h35647569,
                  'h6e756572,    'h66787362,    'h76626173,    'h7479786d,
                  'h6f697579,    'h74726577,    'h67666473,    'h6c6b6a68,
                  'h2c6d6e62,    'h7663787a,    'h787a6171,    'h77737863,
                  'h65646376,    'h72667662,    'h7467626e,    'h79686e6d,
                  'h756a6d2c,    'h72657771,    'h69757974,    'h7361706f,
                  'h68676664,    'h3b6c6b6a,    'h63787a27,    'h6d626e76,
                  'h662f2e2c,    'h80000000};
    data[47] = 'h000004a0;
    compression = 256'h26d707651fcfe0bcef4e732e3a77a89b312aab802dfdee98fc038036a29283e4;
  #1; endtask
  
  task automatic test_vec_5();
    test_str = "test 5-"; t = test_5;
    input_massage ="88866d5a04c2b81f579962b7293928a6a2458381ef4f022fc2ec7a72422b275e0f5588e36c63f371a4ddd72d89308a6d1a41e5edced3f805720ecea64f09d21b1059ff90b5b1f5e9ff7f3374da3ded1d47eb9f6562d0bff48974c0234e5be5fa1f571c984c5d4dc8edbd13d4fffc20b5009578b782b7f6b029d1b1b4c7726ef8870d1b9130d967e6b170352e3c1d04579ad3f1207efca01c6d0d4416329e118a66fb0974bac9a026e5511650a4a2a1c10264cf24c38d0c66f3cf3102e2c5be3e69ffd24fcf964f94dcc329543f8be0b67d3ec91547a61ce928ff1e2d1072c1ab9b499dda9a37847747d0011f6457f03dafdce9e23ea6bbbf4371eae2b4278f914ac099c428bdac62d9e0e28a8c97dfd9942a26bb9323b199787ec001a4fc7d8cda3db0928947ddaa9c73dd1a5a496d6e86adaca8ef5b071bda3269f9a31629d8";
    data = '{default: '0};
    data[0:80] = {'h88866d5a, 'h04c2b81f, 'h579962b7, 'h293928a6,
                  'ha2458381, 'hef4f022f, 'hc2ec7a72, 'h422b275e,
                  'h0f5588e3, 'h6c63f371, 'ha4ddd72d, 'h89308a6d,
                  'h1a41e5ed, 'hced3f805, 'h720ecea6, 'h4f09d21b,
                  'h1059ff90, 'hb5b1f5e9, 'hff7f3374, 'hda3ded1d,
                  'h47eb9f65, 'h62d0bff4, 'h8974c023, 'h4e5be5fa,
                  'h1f571c98, 'h4c5d4dc8, 'hedbd13d4, 'hfffc20b5,
                  'h009578b7, 'h82b7f6b0, 'h29d1b1b4, 'hc7726ef8,
                  'h870d1b91, 'h30d967e6, 'hb170352e, 'h3c1d0457,
                  'h9ad3f120, 'h7efca01c, 'h6d0d4416, 'h329e118a,
                  'h66fb0974, 'hbac9a026, 'he5511650, 'ha4a2a1c1,
                  'h0264cf24, 'hc38d0c66, 'hf3cf3102, 'he2c5be3e,
                  'h69ffd24f, 'hcf964f94, 'hdcc32954, 'h3f8be0b6,
                  'h7d3ec915, 'h47a61ce9, 'h28ff1e2d, 'h1072c1ab,
                  'h9b499dda, 'h9a378477, 'h47d0011f, 'h6457f03d,
                  'hafdce9e2, 'h3ea6bbbf, 'h4371eae2, 'hb4278f91,
                  'h4ac099c4, 'h28bdac62, 'hd9e0e28a, 'h8c97dfd9,
                  'h942a26bb, 'h9323b199, 'h787ec001, 'ha4fc7d8c,
                  'hda3db092, 'h8947ddaa, 'h9c73dd1a, 'h5a496d6e,
                  'h86adaca8, 'hef5b071b, 'hda3269f9, 'ha31629d8,
                  'h80000000};
        data[95] = 'h00000a00;
        compression = 256'h826d606f511f043501117d7ae6cf2e797aadeeb86ecd8be7f59335f32ccb0ac3;
  #1; endtask
  
  task automatic test_vec_6();
  test_str = "test 6-"; t= test_6;
    input_massage ="d364e8f1545ce324431f92858db5d670dbb90c597149fd94402fbef07d04a3f76e5604c98102eec5adb391582c6758b85ddd03f53b1696b125c71235cf692dd45f260dd4fe1e19759544655511310ce88581166caa512601073ddceaa9a0d3608952ecd51bf2a12ed18ad3d8a246c2098d97d8dc762483c49ce8e1ccb4c7ff8721b765046af02a3b44fa8a4ffb474e3c8dfc121c7a4fcf5cf597b269b8465ed838be2884645a504f251846bd82e8ccdcc7f4296b6995d44fd2b3634322c119a11abdcff594756536f1d217d65dfcc6e48dfe4976865425f17f95f9b420368ea99df22598c33f49b0a9f669485e5661682d698fc973c0e1b4627d53fe417e82be13243d29ef5c950f56cb298cedbffac5899ca76c4e785cf683468eb897aca16e0438df074093b0e177e94d707ebece79fe133407a7f48756c5d112f3de2ff50e";
    data = '{default: '0};
    data[0:80] = {'hd364e8f1, 'h545ce324, 'h431f9285, 'h8db5d670,
                  'hdbb90c59, 'h7149fd94, 'h402fbef0, 'h7d04a3f7,
                  'h6e5604c9, 'h8102eec5, 'hadb39158, 'h2c6758b8,
                  'h5ddd03f5, 'h3b1696b1, 'h25c71235, 'hcf692dd4,
                  'h5f260dd4, 'hfe1e1975, 'h95446555, 'h11310ce8,
                  'h8581166c, 'haa512601, 'h073ddcea, 'ha9a0d360,
                  'h8952ecd5, 'h1bf2a12e, 'hd18ad3d8, 'ha246c209,
                  'h8d97d8dc, 'h762483c4, 'h9ce8e1cc, 'hb4c7ff87,
                  'h21b76504, 'h6af02a3b, 'h44fa8a4f, 'hfb474e3c,
                  'h8dfc121c, 'h7a4fcf5c, 'hf597b269, 'hb8465ed8,
                  'h38be2884, 'h645a504f, 'h251846bd, 'h82e8ccdc,
                  'hc7f4296b, 'h6995d44f, 'hd2b36343, 'h22c119a1,
                  'h1abdcff5, 'h94756536, 'hf1d217d6, 'h5dfcc6e4,
                  'h8dfe4976, 'h865425f1, 'h7f95f9b4, 'h20368ea9,
                  'h9df22598, 'hc33f49b0, 'ha9f66948, 'h5e566168,
                  'h2d698fc9, 'h73c0e1b4, 'h627d53fe, 'h417e82be,
                  'h13243d29, 'hef5c950f, 'h56cb298c, 'hedbffac5,
                  'h899ca76c, 'h4e785cf6, 'h83468eb8, 'h97aca16e,
                  'h0438df07, 'h4093b0e1, 'h77e94d70, 'h7ebece79,
                  'hfe133407, 'ha7f48756, 'hc5d112f3, 'hde2ff50e,
                  'h80000000};
      data[95] = 'h00000a00;
      compression = 256'he23e005624bcc730f352a672e6ddd1500ea787eccd386d71485c7e1c953fb898;
  #1; endtask
  
  task automatic test_vec_7();
  test_str = "test 7-"; t= test_7;
    input_massage ="...";
    data[0:127] = {'h48705e99, 'h44da44b4, 'hc8138f30, 'h81a001d2, 'hf28acc16, 'h7456b2c7,
                   'h7b366bcc, 'h1c814745, 'hcc6114d7, 'h6bcc4243, 'h81b5453e, 'hc7833b7d,
                   'he9c2cf0f, 'h8a185def, 'h887b57da, 'h82a2e75e, 'h98b9d534, 'h7259accf,
                   'h84b71835, 'h901c930e, 'h6c9540fa, 'h05eb1728, 'ha4d54325, 'h706dc8f1,
                   'h35e16958, 'h636bc97f, 'h5a83d0be, 'he45350ad, 'h036be982, 'heeb62a9a,
                   'h56acf855, 'hedca3427, 'h293f98ec, 'h45e9e27c, 'h8a7f3580, 'hcc10bc84,
                   'h37ac904d, 'h4c61dc6c, 'h26693f13, 'h02a17128, 'hfe3d2a98, 'h21ba3fee,
                   'h9c150e24, 'h4f3b1db8, 'h8fc0fe03, 'h27d376c7, 'h9c72de07, 'hb6dac81b,
                   'h3b42e603, 'hfec828fc, 'h18ac2551, 'h76bcbc74, 'h940ffb4d, 'h87f63fd2,
                   'h41309dd8, 'h115d8128, 'h69b595d6, 'he4fae5ce, 'h87ab40b0, 'h487be1de,
                   'hcc024fd3, 'h75b181b6, 'h9c0b462e, 'h1b12e479, 'h0f00ffb8, 'hdc38bd8d,
                   'h717c28e8, 'hcd60d41e, 'hc1ffc13c, 'hf8ec829a, 'h366c9fb3, 'hdde23933,
                   'hb58aec52, 'hec6afa61, 'h5c86a5a2, 'h0d54dc5d, 'hfb6f1a30, 'h198f8ca7,
                   'h95b9720d, 'h5eb3c781, 'he4bb244c, 'h1f78e271, 'hd2317f86, 'h113d42c3,
                   'h01bb2259, 'hdf83e504, 'h435c85e4, 'ha66fd789, 'h22fb6e4d, 'h7a4bbee6,
                   'h5ae57d3b, 'he0054f77, 'h5a49a15c, 'h52aed5db, 'hc8bba0e1, 'hbefcb173,
                   'hfab294fd, 'h07c9d5e7, 'h7d0a686a, 'h829248a2, 'h91835fe4, 'h7af9a651,
                   'haa408dab, 'had449d68, 'hf1485c05, 'hcddb719d, 'hc10808ba, 'h00ce786b,
                   'h2bd02397, 'h604c9e90, 'h735113eb, 'h7b2de390, 'h91258f0d, 'hd46ad830,
                   'hb14825d4, 'h619f26fb, 'hb297b71d, 'h0b9007c0, 'haa58f949, 'h31a1ca12,
                   'h61b2f5bc, 'h255c53c7, 'hd230875f, 'hadef9979, 'hae400000, 'h00000000,
                   'h00000000, 'h00000f89 };
      compression = 256'h0637697e16c69aaf54c92a0a4338ba4318235f7ca65937afaf39e5387e06784b;
  #1; endtask

  task automatic running_tests();
    test_vec_1();
    SendBlockData(1); 
    test_vec_2();
    SendBlockData(1); 
    test_vec_3();
    SendBlockData(2);
    test_vec_4();
    SendBlockData(3);
    test_vec_5();
    SendBlockData(6);
    test_vec_6();
    SendBlockData(6);
    test_vec_7();
    SendBlockData(8);
  endtask
  //////////////////////////////////////////////////////
  initial begin
    m_axis_tready <= 1;
    resetn <= 0; #100
    resetn <= 1;
    //////////////////////////////////////////////////////
    running_tests();
  end
endmodule
