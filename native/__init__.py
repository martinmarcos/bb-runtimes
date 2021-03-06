from build_rts_support.bsp import BSP
from build_rts_support.target import DFBBTarget


class NativeBSP(BSP):
    @property
    def name(self):
        return 'native'

    @property
    def add_linker_section(self):
        return False

    def __init__(self):
        super(NativeBSP, self).__init__()
        self.add_sources('crt0', {
            's-macres.adb': 's-macres-native.adb',
            's-textio.adb': 's-textio-stdio.adb'})


class X86Native(DFBBTarget):
    @property
    def name(self):
        return 'x86'

    @property
    def target(self):
        return None

    @property
    def parent(self):
        return NativeBSP

    @property
    def is_native(self):
        return True

    def __init__(self):
        super(X86Native, self).__init__(
            mem_routines=False,
            small_mem=False)

    @property
    def zfp_system_ads(self):
        return 'system-xi-x86.ads'

    def amend_zfp(self, cfg):
        super(X86Native, self).amend_zfp(cfg)
        cfg.rts_xml = (
            '<?xml version="1.0" ?>\n'
            '<gprconfig>\n'
            '  <configuration>\n'
            '  </configuration>\n'
            '</gprconfig>\n')


class X8664Native(X86Native):
    @property
    def name(self):
        return 'x86_64'

    @property
    def zfp_system_ads(self):
        return 'system-xi-x86_64.ads'
