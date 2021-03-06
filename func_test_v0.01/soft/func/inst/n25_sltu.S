#include <asm.h>
#include <regdef.h>
#include <inst_test.h>

LEAF(n25_sltu_test)
    .set noreorder
    addiu s0, s0 ,1
    li  s2, 0x00
###test inst
    TEST_SLTU(0x158f2b29, 0x421c0a42, 0x00000001)
    TEST_SLTU(0x60343bf8, 0xdd17b30a, 0x00000001)
    TEST_SLTU(0x21821644, 0xbf633f70, 0x00000001)
    TEST_SLTU(0x183268bf, 0xda0fad1c, 0x00000001)
    TEST_SLTU(0x97af4180, 0xb77b51da, 0x00000001)
    TEST_SLTU(0x7239a4fb, 0x04f026da, 0x00000000)
    TEST_SLTU(0x4113f292, 0x17168180, 0x00000000)
    TEST_SLTU(0xec1f2d5a, 0x1f2b8827, 0x00000000)
    TEST_SLTU(0x91367184, 0xecb5c188, 0x00000001)
    TEST_SLTU(0xd193dcf8, 0x52954f2c, 0x00000000)
    TEST_SLTU(0xd5fcaa70, 0x230ce6d8, 0x00000000)
    TEST_SLTU(0x3d5542e0, 0x4db4a06c, 0x00000001)
    TEST_SLTU(0xc48a8384, 0x27bb1400, 0x00000000)
    TEST_SLTU(0x699a0fbe, 0xc9db064f, 0x00000001)
    TEST_SLTU(0x4de25b05, 0xb49a8509, 0x00000001)
    TEST_SLTU(0x4473e1bb, 0xdd319dcf, 0x00000001)
    TEST_SLTU(0x05ad2174, 0xf14dce78, 0x00000001)
    TEST_SLTU(0xe1bbfc33, 0x2f2086a0, 0x00000000)
    TEST_SLTU(0x4fe214d0, 0x2265b254, 0x00000000)
    TEST_SLTU(0xcea056ac, 0x13f6c0c0, 0x00000000)
    TEST_SLTU(0xd545aa5e, 0x5eb4fc1a, 0x00000000)
    TEST_SLTU(0xb80f0f3a, 0x5af242ba, 0x00000000)
    TEST_SLTU(0x076fc4db, 0x4fc59e2a, 0x00000001)
    TEST_SLTU(0x6271cbac, 0xe9406d5e, 0x00000001)
    TEST_SLTU(0xd7331578, 0x9d39d4f0, 0x00000000)
    TEST_SLTU(0x6689f1e8, 0x830549ec, 0x00000001)
    TEST_SLTU(0xdd0db690, 0xa4122620, 0x00000000)
    TEST_SLTU(0xebe83100, 0x48d9c13d, 0x00000000)
    TEST_SLTU(0x22a66280, 0xc05e8e00, 0x00000001)
    TEST_SLTU(0x9138d8e8, 0x109f46c2, 0x00000000)
    TEST_SLTU(0xf8fd433f, 0xbc08c128, 0x00000000)
    TEST_SLTU(0x06f481f0, 0x8ccdd828, 0x00000001)
    TEST_SLTU(0x21d5ea2f, 0x96888da5, 0x00000001)
    TEST_SLTU(0x0fa1f028, 0x4d8b4912, 0x00000001)
    TEST_SLTU(0xf72d7340, 0x83f4b638, 0x00000000)
    TEST_SLTU(0x3dde1600, 0xb8b2ca58, 0x00000001)
    TEST_SLTU(0xb38ed2fc, 0x7c493240, 0x00000000)
    TEST_SLTU(0x84834e0c, 0xef636abb, 0x00000001)
    TEST_SLTU(0x83e4a882, 0xd49d0fa0, 0x00000001)
    TEST_SLTU(0x10ed7a38, 0x3fbeaaca, 0x00000001)
    TEST_SLTU(0xcca8a845, 0xaccab9b0, 0x00000000)
    TEST_SLTU(0x24d5a3c0, 0xa6fa7dda, 0x00000001)
    TEST_SLTU(0xc43a8720, 0x8696ca72, 0x00000000)
    TEST_SLTU(0x6a315010, 0xfd19f586, 0x00000001)
    TEST_SLTU(0xcc63ca94, 0x433941dc, 0x00000000)
    TEST_SLTU(0x4d11dae4, 0xb12828ba, 0x00000001)
    TEST_SLTU(0x8ffd30c0, 0xc474bbc0, 0x00000001)
    TEST_SLTU(0xec9cb980, 0x22deebc4, 0x00000000)
    TEST_SLTU(0x79bafd62, 0xb8bae6f0, 0x00000001)
    TEST_SLTU(0x67b59000, 0x7637afba, 0x00000001)
    TEST_SLTU(0x6cd24e2e, 0x245c4d43, 0x00000000)
    TEST_SLTU(0x5d6144dc, 0xb58b778f, 0x00000001)
    TEST_SLTU(0x014cf4cc, 0x7fbe7340, 0x00000001)
    TEST_SLTU(0xa7dfc844, 0xc15b1558, 0x00000001)
    TEST_SLTU(0x2cbee9b7, 0xee71c4d0, 0x00000001)
    TEST_SLTU(0x1a22f920, 0x2f910898, 0x00000001)
    TEST_SLTU(0xbc90e272, 0x213cd464, 0x00000000)
    TEST_SLTU(0x2543d804, 0xb230d4b2, 0x00000001)
    TEST_SLTU(0xe55318f0, 0x758f61b0, 0x00000000)
    TEST_SLTU(0x06d0d250, 0xf1c7d6d0, 0x00000001)
    TEST_SLTU(0xdd41b686, 0xb8f94d58, 0x00000000)
    TEST_SLTU(0xedb1f591, 0xf67ac84c, 0x00000001)
    TEST_SLTU(0x4404df16, 0xe91ae4f0, 0x00000001)
    TEST_SLTU(0x25565ee0, 0xa6121330, 0x00000001)
    TEST_SLTU(0x6d7e1370, 0xc7e32139, 0x00000001)
    TEST_SLTU(0x3dc98258, 0x8b93ffc0, 0x00000001)
    TEST_SLTU(0x0c8dc160, 0x647a3b40, 0x00000001)
    TEST_SLTU(0x3267ed10, 0x900e04e0, 0x00000001)
    TEST_SLTU(0xeb56b226, 0xbe63007a, 0x00000000)
    TEST_SLTU(0x131ee630, 0x362f65ba, 0x00000001)
    TEST_SLTU(0x268831c5, 0xd9c4ac3c, 0x00000001)
    TEST_SLTU(0x751c00fc, 0xee702f68, 0x00000001)
    TEST_SLTU(0x4b9804dc, 0xef7ca5b8, 0x00000001)
    TEST_SLTU(0x233960b8, 0xadf8f658, 0x00000001)
    TEST_SLTU(0x80bcc7a2, 0x00000000, 0x00000000)
    TEST_SLTU(0x4512c5b4, 0x00000000, 0x00000000)
    TEST_SLTU(0x690eca38, 0x00000000, 0x00000000)
    TEST_SLTU(0xcae083a5, 0x00000000, 0x00000000)
    TEST_SLTU(0x6db92ba5, 0x00000000, 0x00000000)
    TEST_SLTU(0xc5a894c9, 0x00000000, 0x00000000)
    TEST_SLTU(0x1dac8320, 0x00000000, 0x00000000)
    TEST_SLTU(0xfe7e8fd4, 0x00000000, 0x00000000)
    TEST_SLTU(0xf5b21a40, 0x00000000, 0x00000000)
    TEST_SLTU(0x99a2b300, 0x00000000, 0x00000000)
    TEST_SLTU(0x80c0dbfc, 0x00000000, 0x00000000)
    TEST_SLTU(0x2a60735a, 0x00000000, 0x00000000)
    TEST_SLTU(0xd2ad8810, 0x00000000, 0x00000000)
    TEST_SLTU(0xd6f657a0, 0x00000000, 0x00000000)
    TEST_SLTU(0x80b5dc22, 0x00000000, 0x00000000)
    TEST_SLTU(0xe9f98f48, 0x00000000, 0x00000000)
    TEST_SLTU(0xb15cf710, 0x00000000, 0x00000000)
    TEST_SLTU(0x09b41b80, 0x00000000, 0x00000000)
    TEST_SLTU(0x1ad7ed46, 0x00000000, 0x00000000)
    TEST_SLTU(0x53b15ae8, 0x00000000, 0x00000000)
    TEST_SLTU(0x30c6b680, 0x00000000, 0x00000000)
    TEST_SLTU(0xe74d39c2, 0x00000000, 0x00000000)
    TEST_SLTU(0xee4a2198, 0x00000000, 0x00000000)
    TEST_SLTU(0x2a4c1f00, 0x00000000, 0x00000000)
    TEST_SLTU(0xa08d0546, 0x00000000, 0x00000000)
    TEST_SLTU(0x94cd0c00, 0x00000000, 0x00000000)
    TEST_SLTU(0xd1d22a40, 0x00000000, 0x00000000)
    TEST_SLTU(0x80025000, 0x00000000, 0x00000000)
    TEST_SLTU(0x11ce1c00, 0x00000000, 0x00000000)
    TEST_SLTU(0x6f255bec, 0x00000000, 0x00000000)
    TEST_SLTU(0xae35b410, 0x00000000, 0x00000000)
    TEST_SLTU(0xc432266a, 0x00000000, 0x00000000)
    TEST_SLTU(0x943f5b66, 0x00000000, 0x00000000)
    TEST_SLTU(0x94282250, 0x00000000, 0x00000000)
    TEST_SLTU(0x5c06de3f, 0x00000000, 0x00000000)
    TEST_SLTU(0x524cc000, 0x00000000, 0x00000000)
    TEST_SLTU(0x24f27490, 0x00000000, 0x00000000)
    TEST_SLTU(0xf725ddc0, 0x00000000, 0x00000000)
    TEST_SLTU(0xdfcbb9d8, 0x00000000, 0x00000000)
    TEST_SLTU(0xc83288d4, 0x00000000, 0x00000000)
    TEST_SLTU(0xfe76d830, 0x00000000, 0x00000000)
    TEST_SLTU(0x630ebd84, 0x00000000, 0x00000000)
    TEST_SLTU(0x03dcb908, 0x00000000, 0x00000000)
    TEST_SLTU(0x8a500d38, 0x00000000, 0x00000000)
    TEST_SLTU(0x844866e0, 0x00000000, 0x00000000)
    TEST_SLTU(0xddf26488, 0x00000000, 0x00000000)
    TEST_SLTU(0x6bf48ff0, 0x00000000, 0x00000000)
    TEST_SLTU(0xf6ac0fac, 0x00000000, 0x00000000)
    TEST_SLTU(0xc94ab2e8, 0x00000000, 0x00000000)
    TEST_SLTU(0x55caaca0, 0x00000000, 0x00000000)
    TEST_SLTU(0x00000000, 0xd2fb1bfc, 0x00000001)
    TEST_SLTU(0x00000000, 0x851e06f7, 0x00000001)
    TEST_SLTU(0x00000000, 0x292277f0, 0x00000001)
    TEST_SLTU(0x00000000, 0xa979b406, 0x00000001)
    TEST_SLTU(0x00000000, 0x3bcaf627, 0x00000001)
    TEST_SLTU(0x00000000, 0x5174d9c0, 0x00000001)
    TEST_SLTU(0x00000000, 0xc50107a4, 0x00000001)
    TEST_SLTU(0x00000000, 0xe381126c, 0x00000001)
    TEST_SLTU(0x00000000, 0xf547978a, 0x00000001)
    TEST_SLTU(0x00000000, 0xfd400d52, 0x00000001)
    TEST_SLTU(0x00000000, 0x28a82746, 0x00000001)
    TEST_SLTU(0x00000000, 0x0b7cc1c0, 0x00000001)
    TEST_SLTU(0x00000000, 0xffddb9c6, 0x00000001)
    TEST_SLTU(0x00000000, 0x10461858, 0x00000001)
    TEST_SLTU(0x00000000, 0x58ef8349, 0x00000001)
    TEST_SLTU(0x00000000, 0x11befc7c, 0x00000001)
    TEST_SLTU(0x00000000, 0x9b360690, 0x00000001)
    TEST_SLTU(0x00000000, 0x0b68d018, 0x00000001)
    TEST_SLTU(0x00000000, 0x800ca9de, 0x00000001)
    TEST_SLTU(0x00000000, 0x346eb190, 0x00000001)
    TEST_SLTU(0x00000000, 0x30ffe000, 0x00000001)
    TEST_SLTU(0x00000000, 0x99c791ec, 0x00000001)
    TEST_SLTU(0x00000000, 0x5aec1334, 0x00000001)
    TEST_SLTU(0x00000000, 0x6c347ff2, 0x00000001)
    TEST_SLTU(0x00000000, 0x64f218fc, 0x00000001)
    TEST_SLTU(0x00000000, 0xfbe31c68, 0x00000001)
    TEST_SLTU(0x00000000, 0xfafd90d4, 0x00000001)
    TEST_SLTU(0x00000000, 0x3892b520, 0x00000001)
    TEST_SLTU(0x00000000, 0x0b757ee4, 0x00000001)
    TEST_SLTU(0x00000000, 0x0e1e5029, 0x00000001)
    TEST_SLTU(0x00000000, 0x34b94fdc, 0x00000001)
    TEST_SLTU(0x00000000, 0xb68d9ab6, 0x00000001)
    TEST_SLTU(0x00000000, 0xd8a2e3ce, 0x00000001)
    TEST_SLTU(0x00000000, 0x90492a8e, 0x00000001)
    TEST_SLTU(0x00000000, 0xe220eeda, 0x00000001)
    TEST_SLTU(0x00000000, 0x0b3133a0, 0x00000001)
    TEST_SLTU(0x00000000, 0xb71bc7ce, 0x00000001)
    TEST_SLTU(0x00000000, 0x2aa746a6, 0x00000001)
    TEST_SLTU(0x00000000, 0x45438a68, 0x00000001)
    TEST_SLTU(0x00000000, 0xc76a5250, 0x00000001)
    TEST_SLTU(0x00000000, 0x39ab0100, 0x00000001)
    TEST_SLTU(0x00000000, 0x52ef4485, 0x00000001)
    TEST_SLTU(0x00000000, 0xad19dd1c, 0x00000001)
    TEST_SLTU(0x00000000, 0xdc03b4c0, 0x00000001)
    TEST_SLTU(0x00000000, 0x2fa8986c, 0x00000001)
    TEST_SLTU(0x00000000, 0xed08ea47, 0x00000001)
    TEST_SLTU(0x00000000, 0x306392cc, 0x00000001)
    TEST_SLTU(0x00000000, 0xba46c85d, 0x00000001)
    TEST_SLTU(0x00000000, 0x059e2da8, 0x00000001)
    TEST_SLTU(0x00000000, 0x32f27784, 0x00000001)
    TEST_SLTU(0x00000000, 0x00000000, 0x00000000)
###detect exception
    bne s2, zero, inst_error
    nop
###score ++
    addiu s3, s3, 1
###output (s0<<24)|s3
inst_error:  
    sll t1, s0, 24
    or t0, t1, s3 
    sw t0, 0(s1)
    jr ra
    nop
END(n25_sltu_test)
