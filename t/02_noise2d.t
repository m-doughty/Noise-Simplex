use Test;
use lib 'lib';
use Noise::Simplex;

plan 7;

# 1. Create a Simplex instance with a known seed
my $simplex = Simplex.new(seed => 12345);
my &noise2d = $simplex.create-noise2d;

# 1. Return value is numeric
ok (noise2d(0.5, 0.5) ~~ Numeric), 'Returns a number';

# 2. Return value is bounded (approximately)
my $val = noise2d(0.5, 0.5);
ok $val >= -1.2 && $val <= 1.2, "Value seems within reasonable range: $val";

# 3. Reproducibility with same seed
my $simplex2 = Simplex.new(seed => 12345);
my &noise2d_b = $simplex2.create-noise2d;
is-approx noise2d(0.7, 0.7), noise2d_b(0.7, 0.7), 'Same seed gives same output';

# 4. Different seed gives different output (usually)
my $simplex3 = Simplex.new(seed => 54321);
my &noise2d_c = $simplex3.create-noise2d;
nok noise2d(0.5, 0.5) == noise2d_c(0.5, 0.5), 'Different seed usually gives different output';
nok noise2d(0.3, 0.7) == noise2d_c(0.3, 0.7), 'Different seed usually gives different output';

# 5. Nearby inputs give similar output (smoothness check)
my $a = noise2d(0.1, 0.1);
my $b = noise2d(0.11, 0.1);

my $a2 = noise2d(0.2, 0.2);
my $b2 = noise2d(0.2, 0.21);

my $delta = abs($a - $b);
ok $delta < 0.1, "Noise is smooth: Δ = $delta";
my $delta2 = abs($a2 - $b2);
ok $delta2 < 0.1, "Noise is smooth: Δ = $delta2";

