build () {
    FILE="$1"
    PROGRAM_NAME=$(basename "$FILE" ".asm")

    if [ ! -f "$FILE" ]; then
        echo "$PROGRAM_NAME not found"
        return
    fi

    echo "Building $PROGRAM_NAME"
    nasm -g -F dwarf -f elf64 "$FILE" -o "./target/$PROGRAM_NAME.o" && ld.lld "./target/$PROGRAM_NAME.o" -o "./target/$PROGRAM_NAME"
}


if [ "$1" = "--clean" ]; then
    rm -r target
    exit
fi

if [ ! -d ./target ]; then
  mkdir ./target
fi

if [ "$#" -eq 0 ]; then
  for FILE in ./src/*.asm ; do
    build "$FILE"
  done
else
  build "src/$1.asm"
fi
