#!/usr/bin/env raku

use lib 'lib';
use Noise::Simplex;
use Image::PNG::Portable;

# Set width/height/number of z levels for noise images.
# Each z-level will be a new image.
my $width = 512;
my $height = 512;
my $z = 8;

# Create a new Noise::Simplex with seed 12345, then return a 3D noise map.
my $simplex = Simplex.new(seed => 12345);
my &noise3d = $simplex.create-noise3d;

# For each z value
for 0 ..^ 8 -> $z {
    # Set up a PNG image of width $width & height $height
    # Note: requires Image::PNG::Portable to be installed.
    my $img = Image::PNG::Portable.new: :$width, :$height, :alpha(False);
    # For each x,y value
    for 0 ..^ $height -> $y {
        for 0 ..^ $width -> $x {
            # Sample the noise at x/y (divide by 64 for very smooth noise).
            my $n = noise3d($x / 64, $y / 64, $z / 64);
            # Add 1 and multiply by 127.5 to get a value between 0 & 255 (RGB)
            my $val = ($n + 1) * 127.5;
            # Set the pixel value of the image to our value derived above.
            $img.set: $x, $y, $val.round, $val.round, $val.round;
        }
    }

    # Save the image in img/3d-z{z level}.png.
    $img.write: "img/3d-z$z.png";
}
