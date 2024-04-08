// SPDX-License-Identifier: MIT
// @sterlingcrispin
pragma solidity ^0.8.20;

// HSV to RGB colorspace conversion
// not totally accurate but should be within 1% or so
contract ColorSpace {
    // expects h: 0-360, s 0-100 , v 0-100
    function hsvToRgb(
        uint256 h,
        uint256 s,
        uint256 v
    ) public pure returns (uint256[3] memory rgb) {
        // Chroma
        uint256 c = (v * s) / 100;
        // Hue section for the 6 sectors of the color wheel
        uint256 hSection = h / 60;
        // Remainder of the hue section scaled to [0, 100]
        uint256 remainder = ((h % 60) * 100) / 60;
        uint256 x = (c * (100 - abs(int256(remainder) - 100))) / 100;
        uint256 m = v - c;

        uint256 r;
        uint256 g;
        uint256 b;

        // Assigning values based on the hue section
        if (hSection == 0) {
            r = c;
            g = x;
            b = 0;
        } else if (hSection == 1) {
            r = x;
            g = c;
            b = 0;
        } else if (hSection == 2) {
            r = 0;
            g = c;
            b = x;
        } else if (hSection == 3) {
            r = 0;
            g = x;
            b = c;
        } else if (hSection == 4) {
            r = x;
            g = 0;
            b = c;
        } else if (hSection == 5) {
            r = c;
            g = 0;
            b = x;
        } else {
            r = g = b = 0; // default to black for safety, should not occur
        }
        // Adjust the color by adding m and scale back to 0-255
        rgb[0] = ((r + m) * 255) / 100;
        rgb[1] = ((g + m) * 255) / 100;
        rgb[2] = ((b + m) * 255) / 100;
        return rgb;
    }

    // absolute value of signed integers
    function abs(int256 x) private pure returns (uint256) {
        return uint256(x < 0 ? -x : x);
    }

    // expects h: 0-360, s 0-100 , v 0-100
    function hsvToRgbAssembly(
        uint256 h,
        uint256 s,
        uint256 v
    ) public pure returns (uint256[3] memory rgb) {
        assembly {
            // Chroma
            let c := div(mul(v, s), 100)
            // Hue section for the 6 sectors of the color wheel
            let hSection := div(h, 60)
            let remainder := mod(h, 60)
            // Remainder of the hue section scaled to [0, 100]
            let remainderScaled := div(mul(remainder, 100), 60)

            // 'abs' logic
            let diff := sub(remainderScaled, 100)
            // Mimic 'abs' by checking if diff is negative, flip the sign
            if slt(diff, 0) {
                diff := sub(0, diff)
            }
            let temp := sub(100, diff)
            let x := div(mul(c, temp), 100)

            // Calculating the match value to adjust the final colors
            let m := sub(v, c)
            let r := 0
            let g := 0
            let b := 0

            // Assigning values based on the hue section
            switch hSection
            case 0 {
                r := c
                g := x
            }
            case 1 {
                r := x
                g := c
            }
            case 2 {
                g := c
                b := x
            }
            case 3 {
                g := x
                b := c
            }
            case 4 {
                r := x
                b := c
            }
            case 5 {
                r := c
                b := x
            }

            // Adjust the color by adding m and scale back to 0-255
            r := div(mul(add(r, m), 255), 100)
            g := div(mul(add(g, m), 255), 100)
            b := div(mul(add(b, m), 255), 100)

            mstore(rgb, r)
            mstore(add(rgb, 32), g)
            mstore(add(rgb, 64), b)
        }
    }
}
