sox -M \
    -r 37800 -e signed-integer -b 16 -c 1 -t raw $1/audio_left.bin \
    -r 37800 -e signed-integer -b 16 -c 1 -t raw $1/audio_right.bin \
    $1_audio.wav
