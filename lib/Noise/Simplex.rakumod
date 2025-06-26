unit module Noise::Simplex;

use Math::Random::MT;

constant $sqrt3 = 3.sqrt;
constant $f2    = 0.5 * ($sqrt3 - 1);
constant $g2    = (3 - $sqrt3) / 6;
constant $f3    = 1/3;
constant $g3    = 1/6;

constant @grad2 = (
	 1,  1,
	-1,  1,
	 1, -1,
	-1, -1,
	 1,  0,
	-1,  0,
	 1,  0,
	-1,  0,
	 0,  1,
	 0, -1,
	 0,  1,
	 0, -1
);

constant @grad3 = (
	 1,  1,  0,
	-1,  1,  0,
	 1, -1,  0,
	-1, -1,  0,
	 1,  0,  1,
	-1,  0,  1,
	 1,  0, -1,
	-1,  0, -1,
	 0,  1,  1,
	 0, -1,  1,
	 0,  1, -1,
	 0, -1, -1
);

class Simplex is export {
	has Int $.seed is required;
	has @!perm;

	has @!perm-grad2x;
	has @!perm-grad2y;

	has @!perm-grad3x;
	has @!perm-grad3y;
	has @!perm-grad3z;

	submethod BUILD(:$!seed) {
		@!perm = self.build-permutation-table;
	}

	method !perm-grad2x {
		if @!perm-grad2x.elems == 0 {
			my @result = @!perm.map( -> $v { @grad2[ ($v % 12) * 2 ] });
			@!perm-grad2x = @result;
		}
		return @!perm-grad2x;
	}

	method !perm-grad2y {
		if @!perm-grad2y.elems == 0 {
			my @result = @!perm.map( -> $v { @grad2[ ($v % 12) * 2 + 1 ] });
			@!perm-grad2y = @result;
		}
		return @!perm-grad2y;
	}

	method !perm-grad3x {
		if @!perm-grad3x.elems == 0 {
			my @result = @!perm.map( -> $v { @grad3[ ($v % 12) * 3 ] });
			@!perm-grad3x = @result;
		}
		return @!perm-grad3x;
	}

	method !perm-grad3y {
		if @!perm-grad3y.elems == 0 {
			my @result = @!perm.map( -> $v { @grad3[ ($v % 12) * 3 + 1 ] });
			@!perm-grad3y = @result;
		}
		return @!perm-grad3y;
	}

	method !perm-grad3z {
		if @!perm-grad3z.elems == 0 {
			my @result = @!perm.map( -> $v { @grad3[ ($v % 12) * 3 + 2 ] });
			@!perm-grad3z = @result;
		}
		return @!perm-grad3z;
	}

	method create-noise2d {
		my @perm        = @!perm;
		my @perm-grad2x = self!perm-grad2x;
		my @perm-grad2y = self!perm-grad2y;

		return sub ($x, $y) {
			my ($n0, $n1, $n2) = (0, 0, 0);

			my $s = ($x + $y) * $f2;
			my $i = ($x + $s).floor;
			my $j = ($y + $s).floor;

			my $t  = ($i + $j) * $g2;
			my $X0 = $i - $t;
			my $Y0 = $j - $t;

			my $x0 = $x - $X0;
			my $y0 = $y - $Y0;

			my ($i1, $j1) = $x0 > $y0 ?? (1, 0) !! (0, 1);

			my $x1 = $x0 - $i1 + $g2;
			my $y1 = $y0 - $j1 + $g2;
			my $x2 = $x0 - 1 + 2 * $g2;
			my $y2 = $y0 - 1 + 2 * $g2;

			my $ii = $i +& 255;
			my $jj = $j +& 255;

			my $t0 = 0.5 - $x0² - $y0²;

			if $t0 >= 0 {
				my $gi0 = @perm[($ii + @perm[$jj]) +& 255];
				my ($gx, $gy) = @perm-grad2x[$gi0], @perm-grad2y[$gi0];
				$t0 *= $t0;
				$n0 = $t0 * $t0 * ($gx * $x0 + $gy * $y0);
			}

			my $t1 = 0.5 - $x1² - $y1²;

			if $t1 >= 0 {
				my $gi1 = $ii + $i1 + @perm[$jj + $j1];
				my ($gx, $gy) = @perm-grad2x[$gi1], @perm-grad2y[$gi1];
				$t1 *= $t1;
				$n1 = $t1 * $t1 * ($gx * $x1 + $gy * $y1);
			}

			my $t2 = 0.5 - $x2² - $y2²;
			if $t2 >= 0 {
				my $gi2 = $ii + 1 + @perm[$jj + 1];
				my ($gx, $gy) = @perm-grad2x[$gi2], @perm-grad2y[$gi2];
				$t2 *= $t2;
				$n2 = $t2 * $t2 * ($gx * $x2 + $gy * $y2);
			}

			return 70 * ($n0 + $n1 + $n2);
		}
	}

	method create-noise3d {
		my @perm        = @!perm;
		my @perm-grad3x = self!perm-grad3x;
		my @perm-grad3y = self!perm-grad3y;
		my @perm-grad3z = self!perm-grad3z;

		return sub ($x, $y, $z) {
			my ($n0, $n1, $n2, $n3) = (0, 0, 0, 0);

			my $s = ($x + $y + $z) * $f3;
			my $i = ($x + $s).floor();
			my $j = ($y + $s).floor();
			my $k = ($z + $s).floor();
			
			my $t  = ($i + $j + $k) * $g3;
			my $X0 = $i - $t;
			my $Y0 = $j - $t;
			my $Z0 = $k - $t;

			my $x0 = $x - $X0;
			my $y0 = $y - $Y0;
			my $z0 = $z - $Z0;

			my ($i1, $j1, $k1, $i2, $j2, $k2);

			if $x0 >= $y0 {
				if $y0 >= $z0      { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (1,0,0, 1,1,0);
				} elsif $x0 >= $z0 { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (1,0,0, 1,0,1);
				} else             { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (0,0,1, 1,0,1);
				}
			} else {
				if $y0 < $z0      { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (0,0,1, 0,1,1);
				} elsif $x0 < $z0 { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (0,1,0, 0,1,1);
				} else            { 
					($i1,$j1,$k1, $i2,$j2,$k2) = (0,1,0, 1,1,0);
				}
			}

			my $x1 = $x0 - $i1 + $g3;
			my $y1 = $y0 - $j1 + $g3;
			my $z1 = $z0 - $k1 + $g3;

			my $x2 = $x0 - $i2 + 2 * $g3;
			my $y2 = $y0 - $j2 + 2 * $g3;
			my $z2 = $z0 - $k2 + 2 * $g3;

			my $x3 = $x0 - 1 + 3 * $g3;
			my $y3 = $y0 - 1 + 3 * $g3;
			my $z3 = $z0 - 1 + 3 * $g3;

			my $ii = $i +& 255;
			my $jj = $j +& 255;
			my $kk = $k +& 255;

			my $gi0 = @perm[($ii + @perm[($jj + @perm[$kk]) +& 255]) +& 255];
			my $t0 = 0.6 - $x0² - $y0² - $z0²;
			if $t0 >= 0 {
				my $gx = @perm-grad3x[$gi0];
				my $gy = @perm-grad3y[$gi0];
				my $gz = @perm-grad3z[$gi0];
				$t0 *= $t0;
				$n0 = $t0 * $t0 * ($gx * $x0 + $gy * $y0 + $gz * $z0);
			}

		        my $gi1 = @perm[($ii + $i1 + @perm[($jj + $j1 + @perm[($kk + $k1) +& 255]) +& 255]) +& 255];
			my $t1 = 0.6 - $x1² - $y1² - $z1²;
			if $t1 >= 0 {
				my $gx = @perm-grad3x[$gi1];
				my $gy = @perm-grad3y[$gi1];
				my $gz = @perm-grad3z[$gi1];
				$t1 *= $t1;
				$n1 = $t1 * $t1 * ($gx * $x1 + $gy * $y1 + $gz * $z1);
			}

			my $gi2 = @perm[($ii + $i2 + @perm[($jj + $j2 + @perm[($kk + $k2) +& 255]) +& 255]) +& 255];
			my $t2 = 0.6 - $x2² - $y2² - $z2²;
			if $t2 >= 0 {
				my $gx = @perm-grad3x[$gi2];
				my $gy = @perm-grad3y[$gi2];
				my $gz = @perm-grad3z[$gi2];
				$t2 *= $t2;
				$n2 = $t2 * $t2 * ($gx * $x2 + $gy * $y2 + $gz * $z2);
			}

			my $gi3 = @perm[($ii + 1 + @perm[($jj + 1 + @perm[($kk + 1) +& 255]) +& 255]) +& 255];
			my $t3 = 0.6 - $x3² - $y3² - $z3²;
			if $t3 >= 0 {
				my $gx = @perm-grad3x[$gi3];
				my $gy = @perm-grad3y[$gi3];
				my $gz = @perm-grad3z[$gi3];
				$t3 *= $t3;
				$n3 = $t3 * $t3 * ($gx * $x3 + $gy * $y3 + $gz * $z3);
			}

			return 32 * ($n0 + $n1 + $n2 + $n3);
		}
	}

	method build-permutation-table {
		my $rng = Math::Random::MT.mt19937_64;
		$rng.setSeed($!seed);

		my @table = (0 .. 255);
		for 0 .. 254 -> $i {
			my $r = $i + $rng.nextInt(256 - $i);
			@table[$i, $r] = @table[$r, $i];
		}
		@table.append: @table;

		return @table;
	}
}
