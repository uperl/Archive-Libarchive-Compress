use warnings;
use 5.020;
use experimental qw( postderef signatures );

package Archive::Libarchive::Compress {

  use Carp ();
  use Path::Tiny ();
  use File::chdir;
  use Ref::Util qw( is_ref is_plain_scalarref is_plain_coderef );
  use Archive::Libarchive 0.04 qw( ARCHIVE_OK ARCHIVE_WARN );

  # ABSTRACT: Recursively compress a directory (using libarchive)

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new

=over 4

=item filename

=item memory

=item entry

=back

=cut

  sub new ($class, %options) {
      Carp::croak("Required option: one of filename or memory")
        unless defined($options{filename} // $options{memory});
      Carp::croak("Exactly one of filename or memory is required")
        if defined($options{filename}) && defined($options{memory});

      if(defined $options{memory} && !(is_plain_scalarref $options{memory} && defined $options{memory}->$* && !is_ref $options{memory}->$*)) {
        Carp::croak("Option memory must be a scalar reference to a plain non-reference scalar");
      }

      Carp::croak("Entry is not a code reference")
        if defined $options{entry} && !is_plain_coderef $options{entry};

      my $self = bless {
        filename   => delete $options{filename},
        entry      => delete($options{entry}) // sub ($e) { return 1 },
        memory     => delete $options{memory},
      }, $class;

      Carp::croak("Illegal options: @{[ sort keys %options ]}")
        if %options;

      return $self;
  }

=head1 METHODS

=head2 filename

=head2 from

=cut

  sub filename   ($self) { return $self->{filename}       }
  sub from       ($self) { return $self->{from}           }

  sub _archive ($self) {
    my $w = Archive::Libarchive::ArchiveWrite->new;
    my $e = Archive::Libarchive::Entry->new;

    $w->set_format_pax_restricted;

    my $ret;

    if($self->filename) {
      $ret = $w->open_filename($self->filename);
    } else {
      $ret = $w->open_memory($self->{memory});
    }

    if($ret == ARCHIVE_WARN) {
      Carp::carp($w->error_string);
    } elsif($ret < ARCHIVE_WARN) {
      Carp::croak($w->error_string);
    }

    return($w,$e);
  }

  sub _iterate ($self, $w, $e, $path) {

    if(-d $path) {
      foreach my $child (sort { $a->basename cmp $b->basename } $path->children) {
        $self->_iterate($w, $e, $child);
      }
    } elsif($self->{entry}->($e)) {
      $e->set_pathname("$path");
      $e->set_filetype('reg');
      $e->set_perm( oct('0644') );
      $e->set_size( -s "$path" );
      my $ret = $w->write_header($e);
      $ret = $w->write_data(\$path->slurp_raw);
    }
  }

=head2 compress

=cut

  sub compress ($self, %options) {
    Carp::croak("Already compressed") if defined $self->from;

    my $from = Path::Tiny->new($options{from} // $CWD);

    my($w, $e) = $self->_archive;

    local $CWD = $from;

    $self->_iterate($w, $e, Path::Tiny->new("."));

    $w->close;

  }
}

1;

