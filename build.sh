# no, I will not use make

QUIET="false"
CLEAN="false"

assemble () {
  FILE="$1"
  PROGRAM_NAME="$2"

  if [ "$QUIET" = "false" ]; then
    echo "Assembling $PROGRAM_NAME"
  fi

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

    if [ "$QUIET" = "false" ]; then
      echo "Linking $PROGRAM_NAME"
    fi

    ld.lld "./target/$PROGRAM_NAME.o" "./target/common.o" -o "./target/$PROGRAM_NAME"
}

clean () {
  if [ -d ./target ]; then
    rm -r target
  fi
}

for ARG in "$@" ; do

  case $ARG in

    "--clean")
      CLEAN="true"
      ;;

    "--quiet" | "-q")
      QUIET="true"
      ;;

    "--help")
      cat << EOF
self-made shitty build script

Run to build all programs into the ./target directory

Options:
  --quiet, -q   | Don't output information
  --clean       | Clean all build artifacts
EOF
      exit
      ;;

  esac
done

if [ "$CLEAN" = "true" ]; then
  clean
  exit
fi

if [ ! -d ./target ]; then
  mkdir ./target
fi

assemble "src/common.asm" "common"

for FILE in ./src/*.asm ; do
  build "$FILE"
done
