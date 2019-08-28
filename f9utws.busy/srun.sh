#/bin/bash

set -x

sudo ./rt-cfg.sh

sudo chrt -f 90 taskset -c 10,11,12,13,14,15,16,17,18 ./run.sh

