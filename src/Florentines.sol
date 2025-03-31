// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Florentines is Ownable {
    uint256 constant SIZE = 64;
    uint256 constant PIXELS = SIZE * SIZE;
    //bytes6 constant COUNT = 0x23070928261C; // [35, 7, 9, 40, 38, 28]

    uint8 constant DECIMALS = 18;

    uint256 constant LAYER_BG = 0;
    uint256 constant LAYER_GUY = 1;
    uint256 constant LAYER_NECK = 2;
    uint256 constant LAYER_HEAD = 3;
    uint256 constant LAYER_EYES = 4;
    uint256 constant LAYER_MOUTH = 5;

    uint256 constant DIST_BG = 0x667889966544667788455662244553333220b8;
    uint256 constant DIST_GUY = 0x783654902a;
    uint256 constant DIST_NECK = 0x1322754611f;
    uint256 constant DIST_HEAD = 0x7698119189248953526119781746848126978461d3;
    uint256 constant DIST_EYES = 0x0086979158114689587275623746781154231821bb;
    uint256 constant DIST_MOUTH = 0x85364593641371253765826874918a;

    uint256 constant COLOR_BIT_BG = 8;

    bytes NAMES_BG =
        "\x23\x05\x0b\x10\x17\x08\x0f\x04\x04\x03\x0a\x04\x0b\x14\x1c\x0e\x16\x2b\x11\x19\x1d\x25\x0f\x17\x10\x18\x18\x0e\x15\x10\x18\x0f\x17\x0f\x06\x14PlainPlain\x2520AltFleur\x2520de\x2520LysFleur\x2520de\x2520Lys\x2520DarkOptimismOptimism\x2520DarkPampDampETHETH\x2520DarkBaseBase\x2520DarkFlorence\x2520CathedralFlorence\x2520Cathedral\x2520NightDoges\x2520PalaceDoges\x2520Palace\x2520NightThe\x2520Tomb\x2520of\x2520Giuliano\x2520de\x2527\x2520MediciPalazzo\x2520VecchioPalazzo\x2520Vecchio\x2520NightBasilica\x2520di\x2520San\x2520LorenzoBasilica\x2520di\x2520San\x2520Lorenzo\x2520NightPalazzo\x2520PittiPalazzo\x2520Pitti\x2520NightSistine\x2520ChapelSistine\x2520Chapel\x2520NightThe\x2520Birth\x2520of\x2520VenusMedici\x2520BallsMedici\x2520Balls\x2520DarkUffizi\x2520GalleryUffizi\x2520Gallery\x2520NightPonte\x2520VecchioPonte\x2520Vecchio\x2520NightPonte\x2520BurianoTetrisSuper\x2520Mario\x2520Bros";
    bytes NAMES_GUY =
        "\x07\x13\x15\x18\x1a\x0c\x0b\x07Sandro\x2520BotticelliLeonardo\x2520da\x2520VinciLorenzo\x2520de\x2527\x2520MediciNiccol\x25C3\x25B2\x2520MachiavelliMichelangeloMona\x2520LisaRaphael";
    bytes NAMES_NECK =
        "\x08\x07\x0c\x06\x0c\x0a\x03\x06\x05BandanaFrankensteinBowtieGold\x2520ChainChainLinksLayPearlsScarf";
    bytes NAMES_HEAD =
        "\x27\x04\x03\x04\x07\x05\x04\x05\x05\x09\x04\x03\x05\x05\x07\x04\x06\x02\x0e\x03\x09\x04\x07\x04\x08\x04\x08\x07\x07\x06\x07\x05\x0a\x05\x06\x10\x07\x04\x03\x03\x252B1MadBeraBirfdayBlownBullChonkCoins\x2523\x2540\x2524DampDedDevilDramaExcitedHaloHermesHPLaurel\x2520CrownLFGLightbulbLoveMKUltraMortComposerPampConfusedRainbowRecycleRocketSparkleStormBewilderedSweatTargetThought\x2520BubbleUnicornx100ZapZZZ";
    bytes NAMES_EYES =
        "\x25\x05\x05\x05\x04\x0b\x06\x05\x0e\x06\x10\x03\x08\x05\x03\x05\x07\x04\x06\x05\x06\x07\x05\x0b\x06\x06\x06\x07\x06\x05\x04\x06\x06\x04\x05\x08\x05\x02AgentAlienAnimeTMNTBlack\x2520EyeCensorCoinsCorpse\x2520PaintCyborgDeal\x2520With\x2520ItDedDiamondsTeddyEKGFlareFlowersHankHeartsInuitLasersMonocleNounsNouns\x2520AltPiratePixelsWizardRoundedShadesSkullSlepEmojisSportsDotsStarzScarfaceVisorVR";
    bytes NAMES_MOUTH =
        "\x1b\x04\x04\x0f\x05\x09\x06\x04\x05\x05\x04\x05\x05\x08\x07\x05\x04\x06\x07\x05\x08\x06\x04\x05\x04\x03\x04\x06AcneBeanSpeech\x2520BubbleChibiCigarilloCringeDashDrunkGrillGritGrossJointLipstickMonsterOh\x2521PipePuppetShockedSmokeSquiggleStokedTeefTenseDirpUghVampZombie";

    string public name = "Florentines";
    string public symbol = "FLOR";
    uint8 public decimals = DECIMALS;

    mapping(uint256 => bytes) _layerData;
    mapping(uint256 => uint256) _tokenData;
    mapping(address => uint256) public balanceOf;
    mapping(bytes6 => bool) _claimed;
    uint256 public minted;
    uint256 public totalSupply;

    constructor() Ownable(msg.sender) {}

    function mint() external {
        _mint(msg.sender, _createUnique());
    }

    function _mint(address to, bytes6 dna) internal {
        require(to != address(0));
        require(!_claimed[dna]);
        _claimed[dna] = true;
        _tokenData[totalSupply++] = uint160(to) | uint256(bytes32(dna));
        balanceOf[to] += 10 ** DECIMALS;
        minted++;
    }

    function _createUnique() internal view returns (bytes6 dna) {
        uint256 rng = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, totalSupply, msg.sender)
            )
        );
        while (true) {
            dna =
                _randomChoice(rng, LAYER_BG, DIST_BG) |
                _randomChoice(rng, LAYER_GUY, DIST_GUY) |
                _randomChoice(rng, LAYER_NECK, DIST_NECK) |
                _randomChoice(rng, LAYER_HEAD, DIST_HEAD) |
                _randomChoice(rng, LAYER_EYES, DIST_EYES) |
                _randomChoice(rng, LAYER_MOUTH, DIST_MOUTH);
            if (!_claimed[dna]) break;
            assembly {
                mstore(0, rng)
                rng := keccak256(0, 32)
            }
        }
    }

    function _randomChoice(
        uint256 rng,
        uint256 layer,
        uint256 dist
    ) internal pure returns (bytes6) {
        unchecked {
            uint256 denom = uint8(dist);
            dist >>= 8;
            uint256 numer = uint48(rng >> (40 * layer)) % denom;
            uint256 acc;
            uint256 index;
            while (true) {
                uint256 w = dist & 15;
                if (w > 0) {
                    acc += w;
                    if (acc > numer) break;
                }
                index++;
                dist >>= 4;
            }
            return bytes6(bytes1(uint8(index))) >> (layer << 3);
        }
    }

    function loadLayerData(bytes calldata v) external onlyOwner {
        require(minted == 0);
        uint256 i;
        uint256 id;
        uint256 size;
        while (i < v.length) {
            id = uint16(bytes2(v[i:i += 2]));
            size = uint16(bytes2(v[i:i += 2]));
            _layerData[id] = v[i:i += size];
        }
    }

    function createRaster(bytes6 dna) public view returns (bytes memory v) {
        v = new bytes(PIXELS);
        uint256 guy = uint8(dna[LAYER_GUY]);
        _drawLayer(v, LAYER_BG, 0, uint8(dna[LAYER_BG]));
        _drawLayer(v, LAYER_GUY, guy, 1);
        _drawLayer(v, LAYER_NECK, guy, uint8(dna[LAYER_NECK]));
        _drawLayer(v, LAYER_HEAD, guy, uint8(dna[LAYER_HEAD]));
        _drawLayer(v, LAYER_EYES, guy, uint8(dna[LAYER_EYES]));
        _drawLayer(v, LAYER_MOUTH, guy, uint8(dna[LAYER_MOUTH]));
    }

    function _drawLayer(
        bytes memory dst,
        uint256 layer,
        uint256 guy,
        uint256 index
    ) internal view {
        bytes memory src = _layerData[(layer << 12) | (guy << 8) | index];
        if (src.length == 0) return;
        uint256 ptr;
        uint256 buf;
        assembly {
            ptr := add(src, 32)
            buf := mload(ptr) // load first word
            ptr := add(ptr, 32)
        }
        (uint256 n, uint256 c) = _readUint(buf, 256, 2); // read previous color
        uint256 i;
        uint256 run;
        while (i < PIXELS) {
            if (n < 18) {
                assembly {
                    let dx := shl(3, shr(3, sub(256, n))) // round down number of bits to load
                    buf := or(shl(dx, buf), shr(sub(256, dx), mload(ptr))) // load them
                    dx := shr(3, dx) // convert to bytes
                    ptr := add(ptr, dx) // update pointer
                    n := add(n, shl(3, dx)) // update available
                }
            }
            (n, run) = _readUint(buf, n, 4); // read small run of pixels [1, 15]
            if (run == 0) {
                (n, run) = _readUint(buf, n, 12); // read large run of pixels
                run += 16;
            }
            uint256 dc;
            (n, dc) = _readUint(buf, n, 2); // new color (5 colors => 4 alternatives => 2 bits)
            c = (c + 1 + dc) % 5; // new color != prev color
            if (c > 0) {
                bytes1 color = bytes1(
                    uint8(layer == LAYER_BG ? (c | COLOR_BIT_BG) : c)
                );
                for (uint256 e = i + run; i < e; i++) {
                    dst[i] = color; // apply color
                }
            } else {
                i += run; // ignore transparent color
            }
        }
    }

    function _readUint(
        uint256 buf,
        uint256 _n,
        uint256 w
    ) internal pure returns (uint256 n_, uint256 u) {
        unchecked {
            u = (buf << (256 - _n)) >> (256 - w);
            n_ = _n - w;
        }
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        uint256 token = _tokenData[id];
        require(token != 0);
        return createMetadata(id, bytes6(bytes32(token)));
    }

    function createMetadata(
        uint256 id,
        bytes6 dna
    ) public view returns (string memory) {
        bytes memory v = new bytes(300000);
        uint256 ptr;
        assembly {
            ptr := add(v, 32)
            mstore(ptr, "data:application/json,%7B%22id%2")
            ptr := add(ptr, 32)
            mstore(ptr, "2%3A                            ")
            ptr := add(ptr, 4)
        }
        ptr = _writeBase10(ptr, id);
        assembly {
            mstore(ptr, "%2C%22attributes%22%3A%5B%7B%22t")
            ptr := add(ptr, 32)
            mstore(ptr, "rait_type%22%3A%22Background%22%")
            ptr := add(ptr, 32)
            mstore(ptr, "2C%22value%22%3A%22             ")
            ptr := add(ptr, 19)
        }
        ptr = _writeName(ptr, NAMES_BG, uint8(dna[LAYER_BG]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Florentine%22%2C%22value%22%3A")
            ptr := add(ptr, 32)
            mstore(ptr, "%22                             ")
            ptr := add(ptr, 3)
        }
        ptr = _writeName(ptr, NAMES_GUY, uint8(dna[LAYER_GUY]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Head%22%2C%22value%22%3A%22   ")
            ptr := add(ptr, 29)
        }
        ptr = _writeName(ptr, NAMES_HEAD, uint8(dna[LAYER_HEAD]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Eyes%22%2C%22value%22%3A%22   ")
            ptr := add(ptr, 29)
        }
        ptr = _writeName(ptr, NAMES_EYES, uint8(dna[LAYER_EYES]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Mouth%22%2C%22value%22%3A%22  ")
            ptr := add(ptr, 30)
        }
        ptr = _writeName(ptr, NAMES_MOUTH, uint8(dna[LAYER_MOUTH]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Neck%22%2C%22value%22%3A%22   ")
            ptr := add(ptr, 29)
        }
        ptr = _writeName(ptr, NAMES_NECK, uint8(dna[LAYER_NECK]));
        assembly {
            mstore(ptr, "%22%7D%2C%7B%22trait_type%22%3A%")
            ptr := add(ptr, 32)
            mstore(ptr, "22Traits%22%2C%22value%22%3A%22 ")
            ptr := add(ptr, 31)
        }
        unchecked {
            uint256 count;
            for (uint256 i; i < 6; i++) if (dna[i] != 0) count++;
            ptr = _writeBase10(ptr, count);
        }
        assembly {
            mstore(ptr, "%22%7D%5D%2C%22image%22%3A%22dat")
            ptr := add(ptr, 32)
            mstore(ptr, "a%3Aimage%2Fsvg%2Bxml%2C%253C%25")
            ptr := add(ptr, 32)
            mstore(ptr, "3Fxml%2520version%253D%25221.0%2")
            ptr := add(ptr, 32)
            mstore(ptr, "522%253F%253E%253Csvg%2520versio")
            ptr := add(ptr, 32)
            mstore(ptr, "n%253D%25221.1%2522%2520xmlns%25")
            ptr := add(ptr, 32)
            mstore(ptr, "3D%2522http%253A%252F%252Fwww.w3")
            ptr := add(ptr, 32)
            mstore(ptr, ".org%252F2000%252Fsvg%2522%2520x")
            ptr := add(ptr, 32)
            mstore(ptr, "mlns%253Axlink%253D%2522http%253")
            ptr := add(ptr, 32)
            mstore(ptr, "A%252F%252Fwww.w3.org%252F1999%2")
            ptr := add(ptr, 32)
            mstore(ptr, "52Fxlink%2522%2520viewBox%253D%2")
            ptr := add(ptr, 32)
            mstore(ptr, "5220%25200%252064%252064%2522%25")
            ptr := add(ptr, 32)
            mstore(ptr, "3E%253Cstyle%253Erect%257Bshape-")
            ptr := add(ptr, 32)
            mstore(ptr, "rendering%253AcrispEdges%257D.f%")
            ptr := add(ptr, 32)
            mstore(ptr, "257Bfilter%253Asaturate%252825%2")
            ptr := add(ptr, 32)
            mstore(ptr, "525%2529%257D.a%257Bfill%253A%25")
            ptr := add(ptr, 32)
            mstore(ptr, "23e0f8d0%257D.b%257Bfill%253A%25")
            ptr := add(ptr, 32)
            mstore(ptr, "238fc070%257D.c%257Bfill%253A%25")
            ptr := add(ptr, 32)
            mstore(ptr, "23346856%257D.d%257Bfill%253A%25")
            ptr := add(ptr, 32)
            mstore(ptr, "23081820%257D%253C%252Fstyle%253")
            ptr := add(ptr, 32)
            mstore(ptr, "E                               ")
            ptr := add(ptr, 1)
        }
        unchecked {
            bytes memory pixels = createRaster(dna);
            uint256 pos;
            for (uint256 y; y < SIZE; y++) {
                uint256 x;
                uint256 end = pos + SIZE;
                uint256 c = uint8(pixels[pos++]);
                uint256 run = 1;
                while (pos < end) {
                    uint256 cc = uint8(pixels[pos++]);
                    if (c == cc) {
                        run++;
                    } else {
                        ptr = _writeRect(ptr, x, y, run, c);
                        x += run;
                        run = 1;
                        c = cc;
                    }
                }
                ptr = _writeRect(ptr, x, y, run, c);
            }
        }
        assembly {
            mstore(ptr, "%253C%252Fsvg%253E%22%7D        ")
            ptr := add(ptr, 24)
            mstore(v, sub(ptr, add(v, 32)))
        }
        return string(v);
    }

    function _writeName(
        uint256 ptr,
        bytes memory names,
        uint256 index
    ) internal pure returns (uint256) {
        if (index == 0) {
            assembly {
                mstore(ptr, "None                            ")
            }
            return ptr + 4;
        }
        uint256 pos = 1;
        for (uint256 i; i < index; i++) {
            pos += uint8(names[i]);
        }
        assembly {
            mstore(ptr, mload(add(add(names, 32), pos)))
        }
        return ptr + uint8(names[index]);
    }

    function _writeRect(
        uint256 ptr,
        uint256 x,
        uint256 y,
        uint256 w,
        uint256 c
    ) internal pure returns (uint256) {
        if (c > 0) {
            assembly {
                mstore(ptr, "%253Crect%2520width%253D%2527   ")
                ptr := add(ptr, 29)
            }
            ptr = _writeBase10(ptr, w);
            assembly {
                mstore(ptr, "%2527%2520x%253D%2527           ")
                ptr := add(ptr, 21)
            }
            ptr = _writeBase10(ptr, x);
            assembly {
                mstore(ptr, "%2527%2520y%253D%2527           ")
                ptr := add(ptr, 21)
            }
            ptr = _writeBase10(ptr, y);
            assembly {
                mstore(ptr, "%2527%2520height%253D%25271%2527")
                ptr := add(ptr, 32)
                mstore(ptr, "%2520class%253D%2527            ")
                ptr := add(ptr, 20)
            }
            if ((c & COLOR_BIT_BG) != 0) {
                c ^= COLOR_BIT_BG;
                assembly {
                    mstore(ptr, "f%2520                          ")
                    ptr := add(ptr, 6)
                }
            }
            assembly {
                mstore8(ptr, add(96, c))
                ptr := add(ptr, 1)
                mstore(ptr, "%2527%252F%253E                 ")
                ptr := add(ptr, 15)
            }
        }
        return ptr;
    }

    function _writeBase10(
        uint256 _ptr,
        uint256 x
    ) internal pure returns (uint256 ptr_) {
        unchecked {
            ptr_ = _ptr + 1; // always write 1 digit
            uint256 temp = x;
            while (temp > 9) {
                temp /= 10;
                ptr_++; // more digits needed
            }
            temp = ptr_; // save ptr
            while (true) {
                --temp; // work backwards
                assembly {
                    mstore8(temp, add(mod(x, 10), 0x30)) // store remainder
                }
                if (temp == _ptr) break;
                x /= 10;
            }
        }
    }
}
