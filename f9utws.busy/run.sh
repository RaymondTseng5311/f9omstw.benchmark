#/bin/bash

{ set +x; } 2>/dev/null; echo '#####################################################'; set -x;
cat fon9cfg/MaPlugins.f9gv

{ set +x; } 2>/dev/null; echo '#####################################################'; set -x;
cat fon9cfg/MaIo.f9gv

{ set +x; } 2>/dev/null; echo '#####################################################'; set -x;
cat fon9cfg/UtwSEC_io.f9gv

{ set +x; } 2>/dev/null; echo '#####################################################'; set -x;
~/devel/output/f9omstw/release/f9utws/f9utws $*

