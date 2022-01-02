          extern     println_num
          extern     open_file_arg

          global     _start

IO_BUF_SIZE EQU 2048

          section   .data
file_not_found_msg:
          db        'File not found', 10, 15
failed_to_read_msg:
          db        'Failed to read', 10, 15
io_buf:   times IO_BUF_SIZE db 0

          section   .text
_start:
          pop       rax                         ; argc

          cmp       rax, 1
          je        stdin_init                  ; if we don't have any arguments, read from stdin

          ; we do have at least one argument, open the file
          pop       rbx                         ; program name
          pop       rax                         ; filename
          call      open_file_arg
          ; test whether there was an error
          cmp       rax, 0
          jl        file_not_found

          mov       rdi, rax
          jmp       init

stdin_init:
          mov       rdi, 0                      ; stdin

init:
          ; the input fd is in rdi at this point
          ; r13 is the character counter
          xor       r13, r13
process:
          mov       rax, 0
          mov       rsi, io_buf
          mov       rdx, IO_BUF_SIZE
          syscall

          ; test whether there was an error
          cmp       rax, 0
          jl        failed_to_read

          add       r13, rax

          cmp       rax, 0
          jnz       process

count_and_print:
          mov       rax, r13
          call      println_num
          xor       rdi, rdi

exit:
          mov       rax, 60
          syscall

failed_to_read:
          mov       rax, 1                      ; write
          mov       rdi, 2                      ; stderr
          mov       rsi, failed_to_read_msg     ; buf
          mov       rdx, 15                     ; len
          jmp       exit

file_not_found:
          mov       rax, 1                     ; write
          mov       rdi, 2                     ; stderr
          mov       rsi, file_not_found_msg    ; buf
          mov       rdx, 15                    ; len
          syscall
          mov       rdi, 1
          jmp       exit
