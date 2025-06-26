use lib 'lib';
use Noise::Simplex;
use Image::PNG::Portable;

my $width = 512;
my $height = 512;
my $simplex = Simplex.new(seed => 12345);
my &noise2d = $simplex.create-noise2d;

my $img = Image::PNG::Portable.new: :$width, :$height, :alpha(False);

my @pixels;
for 0 ..^ $height -> $y {
    for 0 ..^ $width -> $x {
        my $n = noise2d($x / 64, $y / 64);
        my $val = ($n + 1) * 127.5;
        $img.set: $x, $y, $val.round, $val.round, $val.round;  # R, G, B grayscale
    }
}

$img.write: "img/2d.png";

