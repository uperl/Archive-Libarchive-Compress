# Archive::Libarchive::Compress ![static](https://github.com/uperl/Archive-Libarchive-Compress/workflows/static/badge.svg) ![linux](https://github.com/uperl/Archive-Libarchive-Compress/workflows/linux/badge.svg)

Recursively archive a directory (using libarchive)

# SYNOPSIS

```perl
use Archive::Libarchive::Compress;

my $w = Archive::Libarchive::Compress->new( filename => 'foo.tar' );
$w->compress( from => '.' );
```

# DESCRIPTION

This module recursively archives a directory to either a file or
to memory.  This module does not store directory structure, just
the files, so an empty directory will not be represented in the
resulting archive.

# CONSTRUCTOR

## new

```perl
my $w = Archive::Libarchive::Compress->new(%args);
```

Exactly one of `filename` and `memory` are required.  All other
arguments are optional.

- entry

    Callback function called for each entry before it is written to
    the archive.  The entry is passed in as an instance of
    [Archive::Libarchive::Entry](https://metacpan.org/pod/Archive::Libarchive::Entry).  If this callback returns a false
    value, then the entry will not be written to the archive.

    ```perl
    my $w = Archive::Libarchive::Compress->new(
      filename => 'foo.tar',
      entry => sub ($e) {
        # skip "hidden" files
        return $e->pathname !~ /^\./;
      },
    )
    ```

    You may also modify the entry, before it gets written.  This can
    be useful for modifying stored file properties like the owner,
    group or permissions that you may not want in the archive.

- filename

    The name of the archive filename to create.

- memory

    Scalar reference which will be used as a buffer to write the archive
    to memory.  This scalar does not have to be pre-allocated, so this
    will work:

    ```perl
    my $out = '';
    my $w = Archive::Libarchive::Compress->new( memory => \$out );
    ```

- prep

    Callback function called before the archive has been opened.
    An instance of [Archive::Libarchive::ArchiveWrite](https://metacpan.org/pod/Archive::Libarchive::ArchiveWrite) will be passed
    in.  This is useful for specifying a format for the archive.
    If not provided, then pax restricted format will be used.
    (This is uncompressed and widely supported).  If you wanted
    to for example use GNU tar format compressed with bzip2:

    ```perl
    my $w = Archive::Libarchive::Compress->new(
      filename => 'foo.tar.bz2',
      prep => sub ($archive) {
        $archive->set_format_gnutar;
        $archive->add_filter_bzip2;
      },
    );
    ```

    See [Archive::Libarchive::ArchiveWrite](https://metacpan.org/pod/Archive::Libarchive::ArchiveWrite) for more details.

# METHODS

## filename

```perl
my $filename = $w->filename;
```

Returns the Archive filename.

## from

```perl
my $from = $w->from;
```

Returns the directory that was archived.  If ["compress"](#compress) hasn't been called yet,
then it will return `undef`.

## compress

```perl
$w->compress( from => $dir );
$w->compress;
```

Recursively archives the directory.  If `$dir` is not provided, then
the current directory will be used.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
