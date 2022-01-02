assemble () {
  FILE="$1"
  PROGRAM_NAME="$2"

  echo "Assembling $PROGRAM_NAME"
  nasm -g -F dwarf -f elf64 "$FILE" -o "./target/$PROGRAM_NAME.o" || return
}

build () {
    FILE="$1"
    PROGRAM_NAME=$(basename "$FILE" ".asm")

    if [ ! -f "$FILE" ]; then
        echo "$PROGRAM_NAME not found"
        return
    fi


    if [ "$PROGRAM_NAME" = "common" ]; then
      # common does not need to be linked into an executable
      return
    fi

    assemble "$FILE" "$PROGRAM_NAME"

    echo "Linking $PROGRAM_NAME"
    ld.lld "./target/$PROGRAM_NAME.o" "./target/common.o" -o "./target/$PROGRAM_NAME"
}


if [ "$1" = "--clean" ]; then
    rm -r target
    exit
fi

if [ ! -d ./target ]; then
  mkdir ./target
fi


assemble "src/common.asm" "common"

if [ "$#" -eq 0 ]; then
  for FILE in ./src/*.asm ; do
    build "$FILE"
  done
else
  build "src/$1.asm"
fi
