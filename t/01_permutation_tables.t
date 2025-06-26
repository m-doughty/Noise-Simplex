use Test;
use lib 'lib';
use Noise::Simplex;

plan 5;

my $simplex = Simplex.new(seed => 12345);
my @perm = $simplex.build-permutation-table;

# 1. It should return an array with 512 elements (256 duplicated)
is @perm.elems, 512, 'Permutation table has 512 elements';

# 2. The first 256 elements should be a permutation of 0..255
my %seen;
@perm[0..255].map({ %seen{$_}++ });
is %seen.keys.sort( { .Int } ), (0..255), 'First half is permutation of 0..255';

# 3. The second half should be a duplicate of the first
is-deeply @perm[256..511], @perm[0..255], 'Second half duplicates the first';

# 4. Check values are in range
ok all(@perm) ~~ Int && all(@perm) >= 0 && all(@perm) <= 255, 'All values in 0..255';

# 5. Reproducibility with the same seed
my $another-simplex = Simplex.new(seed => 12345);
my @another_perm = $another-simplex.build-permutation-table;
is-deeply @another_perm, @perm, 'Same seed gives same permutation';

