          extern     itoa
          global     _start

          section   .data
itoa_buf: times 100 db 0

          section   .text
_start:
          mov       rax, 45354
          mov       rbx, itoa_buf
          call      itoa

          mov       rdx, rbx
          mov       rax, 1
          mov       rdi, 1
          mov       rsi, itoa_buf
          syscall

          mov       rax, 60
          xor       rdi, rdi
          syscall
