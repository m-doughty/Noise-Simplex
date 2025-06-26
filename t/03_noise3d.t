#!/usr/bin/env raku
use Test;
use lib 'lib';
use Noise::Simplex;

plan 7;

my $seed = 12345;
my $simplex = Simplex.new(seed => $seed);
my &noise3d = $simplex.create-noise3d;

# 1. Returns a number
my $out = noise3d(0.1, 0.2, 0.3);
ok $out ~~ Numeric, 'Returns a number';

# 2. Value seems within reasonable range [-1,1]
ok $out >= -1 && $out <= 1, "Noise value in range [-1,1]";

# 3. Determinism for same seed/inputs
my $out2 = noise3d(0.1, 0.2, 0.3);
is-approx $out, $out2, 1e-8, 'Same seed & input gives same output';

# 4. Different seed gives different value
my $simplex2 = Simplex.new(seed => $seed + 1);
my &noise3d_2 = $simplex2.create-noise3d;
my $other = noise3d_2(0.1, 0.2, 0.3);
ok ($other != $out), 'Different seed gives different output';

# 5. Small change in input yields small change in output (continuity)
my $delta = abs(noise3d(0.1, 0.2, 0.3) - noise3d(0.1001, 0.2001, 0.3001));
ok $delta < 0.01, "Small input change yields small output change";

# 6. Test zero input
ok noise3d(0,0,0) ~~ Numeric, 'Noise at origin returns number';

# 7. Range check on multiple samples
my $all_in_range = all (0..10).map: { noise3d($_/5, $_/7, $_/11) >= -1 && noise3d($_/5, $_/7, $_/11) <= 1 };
ok $all_in_range, "All sampled outputs are in [-1,1]";

