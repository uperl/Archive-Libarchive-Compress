use Test2::V0 -no_srand => 1;
use Archive::Libarchive::Compress;
use Archive::Libarchive::Peek;

subtest 'constructor errors' => sub {

  is(
    dies { Archive::Libarchive::Compress->new },
    match qr/^Required option: one of filename or memory/,
  );

  is(
    dies { Archive::Libarchive::Compress->new( filename => 'foo', memory => \'' ) },
    match qr/^Exactly one of filename or memory is required/,
  );

  is(
    dies { Archive::Libarchive::Compress->new( bogus => 'foo', filename => 'foo' ) },
    match qr/^Illegal options: bogus/,
  );

  is(
    dies { Archive::Libarchive::Compress->new( memory => '' ) },
    match qr/^Option memory must be a scalar reference to a plain non-reference scalar/,
  );

  is(
    dies { Archive::Libarchive::Compress->new( memory => \'', entry => 1 ) },
    match qr/^Entry is not a code reference/,
  );

};

subtest 'memory' => sub {

  my $out = '';

  my $w = Archive::Libarchive::Compress->new( memory => \$out );

  is ref($w), 'Archive::Libarchive::Compress';

  $w->compress( from => 'corpus/single' );

  is(
    Archive::Libarchive::Peek->new( memory => \$out)->file('hello.txt'),
    "hello world\n",
  );

};

subtest 'file' => sub {

  my $out = Path::Tiny->tempfile;

  my $w = Archive::Libarchive::Compress->new( filename => "$out" );

  is ref($w), 'Archive::Libarchive::Compress';

  $w->compress( from => 'corpus/single' );

  is(
    Archive::Libarchive::Peek->new( filename => "$out" )->file('hello.txt'),
    "hello world\n",
  );

};

done_testing;


