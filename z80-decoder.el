;
; Z80-DECODER
;
; This takes care of decoding an instruction, finding its operands if any
; and calling the correct evaluator function with the operands.

(require 'cl)
(require 'z80-memory)
(require 'z80-evaluator)
(provide 'z80-decoder)


(defstruct z80-decoder  memory evaluator)


(defun z80-decoder-no-operands (selector)
  (lexical-let ((selector selector))
    (lambda (decoder start-address next-address)
      (let* ((evaluator (z80-decoder-evaluator decoder))
             (action (funcall selector evaluator)))
        (funcall action evaluator start-address next-address)))))


; If the operator was an argument to the function, then the register could
; be extracted from it.  Since it isn't the register number has to be passed
; in explicitly.

(defun z80-decoder-reg-operand (selector reg)
  (lexical-let ((selector selector) (reg reg))
    (lambda (decoder start-address operand-address)
      (let* ((evaluator (z80-decoder-evaluator decoder))
             (action (funcall selector evaluator)))
        (funcall action evaluator start-address operand-address reg)))))



(defun z80-decoder-byte-operand (selector)
  (lexical-let ((selector selector))
    (lambda (decoder start-address operand-address)
      (let* ((evaluator (z80-decoder-evaluator decoder))
	     (action (funcall selector evaluator))
             (memory (z80-decoder-memory decoder))
             (read-byte (z80-memory-read-byte memory))
             (byte (funcall read-byte memory operand-address))
             (next-address (z80-address-next operand-address)))
        (funcall action evaluator start-address next-address byte)))))



(defun z80-decoder-word-operand (selector)
  (lexical-let ((selector selector))
    (lambda (decoder start-address operand-address)
      (let* ((evaluator (z80-decoder-evaluator decoder))
             (action (funcall selector evaluator))
             (memory (z80-decoder-memory decoder))
             (word (z80-memory-word memory operand-address))
             (next-address (z80-address-delta operand-address 2)))
        (funcall action evaluator start-address next-address word)))))



(defconst z80-decoder-table-cb
  (vector (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-rlc-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-rlc-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-rrc-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-rrc-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-rl-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-rl-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-rr-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-rr-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-sla-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-sla-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-sra-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-sra-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-srl-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-srl-reg 7)))



(defun z80-decoder-cb (decoder start-address next-address)
  (let* ((memory (z80-decoder-memory decoder))
         (byte (funcall (z80-memory-read-byte memory) memory next-address))
         (operand-address (z80-address-next next-address)))
    (if (< byte (length z80-decoder-table-cb))
        (let ((decode-action (aref z80-decoder-table-cb byte)))
          (funcall decode-action decoder start-address operand-address))
      (labels ((doit (reg hl)
                 (let ((evaluator (z80-decoder-evaluator decoder))
                       (bit (logand (lsh byte -3) 7)))
                   (if (= (logand byte 7) 6)
                       (let ((action (funcall hl evaluator)))
                         (funcall action evaluator start-address operand-address bit))
                     (let ((reg-num (logand byte 7))
                           (action (funcall reg evaluator)))
                       (funcall action evaluator start-address operand-address bit reg-num))))))
        (case (lsh byte -6)
          (0 (funcall (z80-decoder-no-operands #'z80-evaluator-illegal)
                      decoder start-address operand-address))
          (1 (doit #'z80-evaluator-bit-reg #'z80-evaluator-bit-hl))
          (2 (doit #'z80-evaluator-set-reg #'z80-evaluator-set-hl))
          (3 (doit #'z80-evaluator-res-reg #'z80-evaluator-res-hl)))))))



(defun z80-decoder-dd (decoder start-address next-address)
  (let* ((memory (z80-decoder-memory decoder))
         (byte (funcall (z80-memory-read-byte memory) memory next-address))
         (operand-address (z80-address-next next-address)))
    (labels ((doit (action)
               (funcall action decoder start-address operand-address)))
      (case byte
        (33  (doit (z80-decoder-word-operand #'z80-evaluator-ld-ix-imm)))
        (34  (doit (z80-decoder-word-operand #'z80-evaluator-st-ix)))
        (35  (doit (z80-decoder-no-operands  #'z80-evaluator-inc-ix)))
        (42  (doit (z80-decoder-word-operand #'z80-evaluator-ld-ix-addr)))
        (43  (doit (z80-decoder-no-operands  #'z80-evaluator-dec-ix)))
        (52  (doit (z80-decoder-byte-operand #'z80-evaluator-inc-ix-disp)))
        (53  (doit (z80-decoder-byte-operand #'z80-evaluator-dec-ix-disp)))
        (134 (doit (z80-decoder-byte-operand #'z80-evaluator-add-a-ix-disp)))
        (142 (doit (z80-decoder-byte-operand #'z80-evaluator-adc-a-ix-disp)))
        (150 (doit (z80-decoder-byte-operand #'z80-evaluator-sub-ix-disp)))
        (158 (doit (z80-decoder-byte-operand #'z80-evaluator-sbc-ix-disp)))
        (166 (doit (z80-decoder-byte-operand #'z80-evaluator-and-ix-disp)))
        (174 (doit (z80-decoder-byte-operand #'z80-evaluator-xor-ix-disp)))
        (182 (doit (z80-decoder-byte-operand #'z80-evaluator-or-ix-disp)))
        (190 (doit (z80-decoder-byte-operand #'z80-evaluator-cp-ix-disp)))
        (225 (doit (z80-decoder-no-operands  #'z80-evaluator-pop-ix)))
        (227 (doit (z80-decoder-no-operands  #'z80-evaluator-ex-sp-ix)))
        (229 (doit (z80-decoder-no-operands  #'z80-evaluator-push-ix)))
        (233 (doit (z80-decoder-no-operands  #'z80-evaluator-jp-ix)))
        (249 (doit (z80-decoder-no-operands  #'z80-evaluator-ld-sp-ix)))
        (t   (doit (z80-decoder-no-operands  #'z80-evaluator-illegal)))))))



(defun z80-decoder-ed (decoder start-address next-address)
  (let* ((memory (z80-decoder-memory decoder))
         (byte (funcall (z80-memory-read-byte memory) memory next-address))
         (operand-address (z80-address-next next-address)))
    (labels ((doit (action)
               (funcall action decoder start-address operand-address)))
      (case byte
        (68  (doit (z80-decoder-no-operands #'z80-evaluator-neg)))
        (69  (doit (z80-decoder-no-operands #'z80-evaluator-ret-n)))
        (71  (doit (z80-decoder-no-operands #'z80-evaluator-ld-i-a)))
        (77  (doit (z80-decoder-no-operands #'z80-evaluator-reti)))
        (78  (doit (z80-decoder-no-operands #'z80-evaluator-ld-r-a)))
        (87  (doit (z80-decoder-no-operands #'z80-evaluator-ld-a-i)))
        (88  (doit (z80-decoder-no-operands #'z80-evaluator-ld-a-r)))
        (103 (doit (z80-decoder-no-operands #'z80-evaluator-rrd)))
        (111 (doit (z80-decoder-no-operands #'z80-evaluator-rld)))
        (160 (doit (z80-decoder-no-operands #'z80-evaluator-ldi)))
        (161 (doit (z80-decoder-no-operands #'z80-evaluator-cpi)))
        (162 (doit (z80-decoder-no-operands #'z80-evaluator-ini)))
        (163 (doit (z80-decoder-no-operands #'z80-evaluator-outi)))
        (168 (doit (z80-decoder-no-operands #'z80-evaluator-ldd)))
        (169 (doit (z80-decoder-no-operands #'z80-evaluator-cpd)))
        (170 (doit (z80-decoder-no-operands #'z80-evaluator-ind)))
        (171 (doit (z80-decoder-no-operands #'z80-evaluator-outd)))
        (176 (doit (z80-decoder-no-operands #'z80-evaluator-ldir)))
        (177 (doit (z80-decoder-no-operands #'z80-evaluator-cpir)))
        (178 (doit (z80-decoder-no-operands #'z80-evaluator-inir)))
        (179 (doit (z80-decoder-no-operands #'z80-evaluator-otir)))
        (184 (doit (z80-decoder-no-operands #'z80-evaluator-lddr)))
        (185 (doit (z80-decoder-no-operands #'z80-evaluator-cpdr)))
        (186 (doit (z80-decoder-no-operands #'z80-evaluator-indr)))
        (187 (doit (z80-decoder-no-operands #'z80-evaluator-otdr)))
        (t   (doit (z80-decoder-no-operands #'z80-evaluator-illegal)))))))



(defun z80-decoder-fd (decoder start-address next-address)
  (let* ((memory (z80-decoder-memory decoder))
         (byte (funcall (z80-memory-read-byte memory) memory next-address))
         (operand-address (z80-address-next next-address)))
    (labels ((doit (action)
               (funcall action decoder start-address operand-address)))
      (case byte
        (33  (doit (z80-decoder-word-operand #'z80-evaluator-ld-iy-imm)))
        (34  (doit (z80-decoder-word-operand #'z80-evaluator-st-iy)))
        (35  (doit (z80-decoder-no-operands  #'z80-evaluator-inc-iy)))
        (42  (doit (z80-decoder-word-operand #'z80-evaluator-ld-iy-addr)))
        (43  (doit (z80-decoder-no-operands  #'z80-evaluator-dec-iy)))
        (52  (doit (z80-decoder-byte-operand #'z80-evaluator-inc-iy-disp)))
        (53  (doit (z80-decoder-byte-operand #'z80-evaluator-dec-iy-disp)))
        (134 (doit (z80-decoder-byte-operand #'z80-evaluator-add-a-iy-disp)))
        (142 (doit (z80-decoder-byte-operand #'z80-evaluator-adc-a-iy-disp)))
        (150 (doit (z80-decoder-byte-operand #'z80-evaluator-sub-iy-disp)))
        (158 (doit (z80-decoder-byte-operand #'z80-evaluator-sbc-iy-disp)))
        (166 (doit (z80-decoder-byte-operand #'z80-evaluator-and-iy-disp)))
        (174 (doit (z80-decoder-byte-operand #'z80-evaluator-xor-iy-disp)))
        (182 (doit (z80-decoder-byte-operand #'z80-evaluator-or-iy-disp)))
        (190 (doit (z80-decoder-byte-operand #'z80-evaluator-cp-iy-disp)))
        (225 (doit (z80-decoder-no-operands  #'z80-evaluator-pop-iy)))
        (227 (doit (z80-decoder-no-operands  #'z80-evaluator-ex-sp-iy)))
        (229 (doit (z80-decoder-no-operands  #'z80-evaluator-push-iy)))
        (233 (doit (z80-decoder-no-operands  #'z80-evaluator-jp-iy)))
        (249 (doit (z80-decoder-no-operands  #'z80-evaluator-ld-sp-iy)))
        (t   (doit (z80-decoder-no-operands  #'z80-evaluator-illegal)))))))



(defconst z80-decoder-table-first-byte
  (vector (z80-decoder-no-operands  #'z80-evaluator-nop)
          (z80-decoder-word-operand #'z80-evaluator-ld-bc-imm)
          (z80-decoder-no-operands  #'z80-evaluator-ld-bc-a)
          (z80-decoder-no-operands  #'z80-evaluator-inc-bc)
          (z80-decoder-no-operands  #'z80-evaluator-inc-b)
          (z80-decoder-no-operands  #'z80-evaluator-dec-b)
          (z80-decoder-byte-operand #'z80-evaluator-ld-b-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rcla)

          (z80-decoder-no-operands  #'z80-evaluator-ex-af)
          (z80-decoder-no-operands  #'z80-evaluator-add-hl-bc)
          (z80-decoder-no-operands  #'z80-evaluator-ld-a-bc)
          (z80-decoder-no-operands  #'z80-evaluator-dec-bc)
          (z80-decoder-no-operands  #'z80-evaluator-inc-c)
          (z80-decoder-no-operands  #'z80-evaluator-dec-c)
          (z80-decoder-byte-operand #'z80-evaluator-ld-c-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rrca)

          (z80-decoder-byte-operand #'z80-evaluator-djnz)
          (z80-decoder-word-operand #'z80-evaluator-ld-de-imm)
          (z80-decoder-no-operands  #'z80-evaluator-ld-de-a)
          (z80-decoder-no-operands  #'z80-evaluator-inc-de)
          (z80-decoder-no-operands  #'z80-evaluator-inc-d)
          (z80-decoder-no-operands  #'z80-evaluator-dec-d)
          (z80-decoder-byte-operand #'z80-evaluator-ld-d-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rla)

          (z80-decoder-byte-operand #'z80-evaluator-jr)
          (z80-decoder-no-operands  #'z80-evaluator-add-hl-de)
          (z80-decoder-no-operands  #'z80-evaluator-ld-a-de)
          (z80-decoder-no-operands  #'z80-evaluator-dec-de)
          (z80-decoder-no-operands  #'z80-evaluator-inc-e)
          (z80-decoder-no-operands  #'z80-evaluator-dec-e)
          (z80-decoder-byte-operand #'z80-evaluator-ld-e-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rra)

          (z80-decoder-byte-operand #'z80-evaluator-jr-nz)
          (z80-decoder-word-operand #'z80-evaluator-ld-hl-imm)
          (z80-decoder-word-operand #'z80-evaluator-st-hl)
          (z80-decoder-no-operands  #'z80-evaluator-inc-hl)
          (z80-decoder-no-operands  #'z80-evaluator-inc-h)
          (z80-decoder-no-operands  #'z80-evaluator-dec-h)
          (z80-decoder-byte-operand #'z80-evaluator-ld-e-imm)
          (z80-decoder-no-operands  #'z80-evaluator-daa)

          (z80-decoder-byte-operand #'z80-evaluator-jr-z)
          (z80-decoder-no-operands  #'z80-evaluator-add-hl-hl)
          (z80-decoder-word-operand #'z80-evaluator-ld-hl-addr)
          (z80-decoder-no-operands  #'z80-evaluator-dec-hl)
          (z80-decoder-no-operands  #'z80-evaluator-inc-l)
          (z80-decoder-no-operands  #'z80-evaluator-dec-l)
          (z80-decoder-byte-operand #'z80-evaluator-ld-l-imm)
          (z80-decoder-no-operands  #'z80-evaluator-cpl)

          (z80-decoder-byte-operand #'z80-evaluator-jr-nc)
          (z80-decoder-word-operand #'z80-evaluator-ld-sp-imm)
          (z80-decoder-word-operand #'z80-evaluator-st-a)
          (z80-decoder-no-operands  #'z80-evaluator-inc-sp)
          (z80-decoder-no-operands  #'z80-evaluator-inc-hl-addr)
          (z80-decoder-no-operands  #'z80-evaluator-dec-hl-addr)
          (z80-decoder-byte-operand #'z80-evaluator-st-hl-imm)
          (z80-decoder-no-operands  #'z80-evaluator-scf)

          (z80-decoder-byte-operand #'z80-evaluator-jr-c)
          (z80-decoder-word-operand #'z80-evaluator-add-hl-sp)
          (z80-decoder-word-operand #'z80-evaluator-ld-a-addr)
          (z80-decoder-no-operands  #'z80-evaluator-dec-sp)
          (z80-decoder-no-operands  #'z80-evaluator-inc-a)
          (z80-decoder-no-operands  #'z80-evaluator-dec-a)
          (z80-decoder-word-operand #'z80-evaluator-ld-a-imm)
          (z80-decoder-no-operands  #'z80-evaluator-ccf)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-b-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-b-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-c-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-c-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-d-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-d-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-e-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-e-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-h-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-h-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-l-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-l-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-halt)
          (z80-decoder-reg-operand  #'z80-evaluator-st-hl-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-ld-a-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-ld-a-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-add-a-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-add-a-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-adc-a-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-adc-a-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-sub-a-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-sub-a-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-sbc-a-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-sbc-a-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-and-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-and-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-xor-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-xor-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-or-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-or-reg 7)

          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 0)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 1)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 2)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 3)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 4)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 5)
          (z80-decoder-no-operands  #'z80-evaluator-cp-hl)
          (z80-decoder-reg-operand  #'z80-evaluator-cp-reg 7)

          (z80-decoder-no-operands  #'z80-evaluator-ret-nz)
          (z80-decoder-no-operands  #'z80-evaluator-pop-bc)
          (z80-decoder-word-operand #'z80-evaluator-jp-nz)
          (z80-decoder-word-operand #'z80-evaluator-jp)
          (z80-decoder-word-operand #'z80-evaluator-call-nz)
          (z80-decoder-no-operands  #'z80-evaluator-push-bc)
          (z80-decoder-byte-operand #'z80-evaluator-add-a-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-00)

          (z80-decoder-no-operands  #'z80-evaluator-ret-z)
          (z80-decoder-no-operands  #'z80-evaluator-ret)
          (z80-decoder-word-operand #'z80-evaluator-jp-z)
          #'z80-decoder-cb
          (z80-decoder-word-operand #'z80-evaluator-call-z)
          (z80-decoder-word-operand #'z80-evaluator-call)
          (z80-decoder-byte-operand #'z80-evaluator-adc-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-08)

          (z80-decoder-no-operands  #'z80-evaluator-ret-nc)
          (z80-decoder-no-operands  #'z80-evaluator-pop-de)
          (z80-decoder-word-operand #'z80-evaluator-jp-nc)
          (z80-decoder-byte-operand #'z80-evaluator-out-a)
          (z80-decoder-word-operand #'z80-evaluator-call-nc)
          (z80-decoder-no-operands  #'z80-evaluator-push-de)
          (z80-decoder-byte-operand #'z80-evaluator-sub-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-10)

          (z80-decoder-no-operands  #'z80-evaluator-ret-c)
          (z80-decoder-no-operands  #'z80-evaluator-exx)
          (z80-decoder-word-operand #'z80-evaluator-jp-c)
          (z80-decoder-byte-operand #'z80-evaluator-in-a)
          (z80-decoder-word-operand #'z80-evaluator-call-c)
          #'z80-decoder-dd   
          (z80-decoder-byte-operand #'z80-evaluator-sbc-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-18)

          (z80-decoder-no-operands  #'z80-evaluator-ret-po)
          (z80-decoder-no-operands  #'z80-evaluator-pop-hl)
          (z80-decoder-word-operand #'z80-evaluator-jp-po)
          (z80-decoder-no-operands  #'z80-evaluator-ex-sp-hl)
          (z80-decoder-word-operand #'z80-evaluator-call-po)
          (z80-decoder-no-operands  #'z80-evaluator-push-hl)
          (z80-decoder-byte-operand #'z80-evaluator-and-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-20)

          (z80-decoder-no-operands  #'z80-evaluator-ret-pe)
          (z80-decoder-no-operands  #'z80-evaluator-jp-hl)
          (z80-decoder-word-operand #'z80-evaluator-jp-pe)
          (z80-decoder-no-operands  #'z80-evaluator-ex-de-hl)
          (z80-decoder-word-operand #'z80-evaluator-call-pe)
          #'z80-decoder-ed
          (z80-decoder-byte-operand #'z80-evaluator-xor-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-28)

          (z80-decoder-no-operands  #'z80-evaluator-ret-p)
          (z80-decoder-no-operands  #'z80-evaluator-pop-af)
          (z80-decoder-word-operand #'z80-evaluator-jp-p)
          (z80-decoder-no-operands  #'z80-evaluator-di)
          (z80-decoder-word-operand #'z80-evaluator-call-p)
          (z80-decoder-no-operands  #'z80-evaluator-push-af)
          (z80-decoder-byte-operand #'z80-evaluator-or-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-30)

          (z80-decoder-no-operands  #'z80-evaluator-ret-m)
          (z80-decoder-no-operands  #'z80-evaluator-ld-sp-hl)
          (z80-decoder-word-operand #'z80-evaluator-jp-m)
          (z80-decoder-no-operands  #'z80-evaluator-ei)
          (z80-decoder-word-operand #'z80-evaluator-call-m)
          #'z80-decoder-fd
          (z80-decoder-byte-operand #'z80-evaluator-cp-imm)
          (z80-decoder-no-operands  #'z80-evaluator-rst-38)))



(defun z80-decode (decoder address)
  "Using the DECODER, decode and evaluate the instruction at the ADDRESS,
returning the address of the next instruction."
  (let* ((memory (z80-decoder-memory decoder))
         (first-byte (funcall (z80-memory-read-byte memory) memory address))
         (next-address (z80-address-next address))
         (decode-action (aref z80-decoder-table-first-byte first-byte)))
    (funcall decode-action decoder address next-address)))
