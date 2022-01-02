          extern     open_file_arg
          extern     println_num

          global     _start

IO_BUF_SIZE  EQU 2048
STDIN_FD     EQU 0
STDOUT_FD    EQU 1

          section   .data
file_not_found_msg:
          db        'File not found', 10, 15
failed_to_read_msg:
          db        'Failed to read', 10, 15
io_buf:   times IO_BUF_SIZE db 0
newline:  db        10, 1

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

          mov       r12, rax
          jmp       init

stdin_init:
          mov       r12, STDIN_FD

init:
          ; the input fd is in r12 at this point
process:
          ; read in from the file
          mov       rdi, r12
          mov       rax, 0
          mov       rsi, io_buf
          mov       rdx, IO_BUF_SIZE
          syscall

          cmp       rax, 0
          jz        finish

          ; test whether there was an error
          cmp       rax, 0
          jl        failed_to_read

          ; write to the file
          mov       rdx, rax
          mov       rax, 1
          mov       rsi, io_buf
          mov       rdi, STDOUT_FD
          syscall

          jmp       process

finish:
          ; write a trailing newline
          mov       rax, 1
          mov       rdx, 1
          mov       rsi, newline
          mov       rdi, STDOUT_FD
          syscall

exit_success:
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
