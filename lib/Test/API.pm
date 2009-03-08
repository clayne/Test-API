# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package Test::API;
use strict;
use warnings;
use Devel::Symdump ();

our $VERSION = '0.001';
$VERSION = eval $VERSION; ## no critic

use base 'Test::Builder::Module';
our @EXPORT = qw/public_ok/;

sub public_ok ($;@) { ## no critic
  my ($package, @expected) = @_;
  my $tb = __PACKAGE__->builder;
  my @fcns = _public_fcns($package);
  my ($missing, $extra) = _difference( \@expected, \@fcns );
  my $ok = $tb->ok(!@$missing && !@$extra, "public API for $package");
  if ( !$ok ) {
    $tb->diag( "missing: @$missing" ) if @$missing;
    $tb->diag( "extra: @$extra" ) if @$extra;
  }
  return $ok;
}

sub _difference {
  my ($array1, $array2) = @_;
  my (%only1, %only2);
  @only1{ @$array1 } = (1) x @$array1;
  delete @only1{ @$array2 };
  @only2{ @$array2 } = (1) x @$array2;
  delete @only2{ @$array1 };
  return ([keys %only1], [keys %only2]);
}

sub _public_fcns {
  my ($package) = @_;
  my $symbols = Devel::Symdump->new( $package );
  return  grep  { substr($_,0,1) ne '_' } 
          map   { (my $f = $_) =~ s/^$package\:://; $f } 
          $symbols->functions;
}

1;

__END__

=begin wikidoc

= NAME

Test::API - Test a list of subroutines provided by a module

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

    use Test::More tests => 2;
    use Test::API;

    require_ok( 'My::Package' );
    public_ok ( 'My::Package', @names );

= DESCRIPTION

This simple test module checks the subroutines provided by a module.  This is
useful for confirming a planned API in testing and ensuring that other
functions aren't unintentionally included via import.

= USAGE

== public_ok

  public_ok( $package, @names );

This function checks that all of the {@names} provided are available within the
{$package} namespace and that *only* these subroutines are available.  This
means that subroutines imported from other modules will cause this test to fail
unless they are explicitly included in {@names}.

Subroutines in {$package} starting with an underscore are excluded from 
consideration.  Therefore, do not include subroutines with an underscore in 
{@names}.

= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=Test-API]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO

* [Test::ClassAPI] -- more geared towards class trees with inheritance

= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2009 by David A. Golden. All rights reserved.

Licensed under Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://www.apache.org/licenses/LICENSE-2.0

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut
