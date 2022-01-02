          extern     itoa
          extern     println_num

          global     _start

IO_BUF_SIZE EQU 1024

          section   .data
io_buf:   times IO_BUF_SIZE db 0

          section   .text
_start:
          ; r13 is the character counter
          xor       r13, r13

process:
          mov       rax, 0
          mov       rdi, 0              ; stdin
          mov       rsi, io_buf
          mov       rdx, IO_BUF_SIZE
          syscall

          add       r13, rax

count_and_print:
          mov       rax, r13
          call      println_num

          mov       rax, 60
          xor       rdi, rdi
          syscall
