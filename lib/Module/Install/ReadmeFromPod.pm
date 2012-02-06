package Module::Install::ReadmeFromPod;

use 5.006;
use strict;
use warnings;
use base qw(Module::Install::Base);
use vars qw($VERSION);

$VERSION = '0.13';

sub readme_from {
  my $self = shift;
  return unless $self->is_admin;

  my $file   = shift || $self->_all_from
    or die "Can't determine file to make readme_from";
  my $clean  = shift || 0;
  my $format = shift || 'txt';

  print "readme_from $file to $format\n";
  
  my $out;
  if ($format eq 'txt') {
    $out = $self->_readme_txt($file);
  } elsif ($format eq 'htm') {
    $out = $self->_readme_htm($file);
  } elsif ($format eq 'man') {
    $out = $self->_readme_man($file);
  }

  if ($clean) {
    $self->clean_files($out);
  }

  return 1;
}


sub _readme_txt {
  my ($self, $in_file) = @_;
  require Pod::Text;
  my $out_file = 'README';
  my $parser = Pod::Text->new();
  open my $out_fh, "> $out_file" or die "Could not write file $out_file: $!\n";
  $parser->output_fh( *$out_fh );
  $parser->parse_file( $in_file );
  return $out_file;
}


sub _readme_htm {
  my ($self, $in_file) = @_;
  require Pod::Html;
  my $out_file = 'README.htm';
  Pod::Html::pod2html(
    "--infile=$in_file",
    "--outfile=$out_file",
  );
  # Remove temporary files if needed
  for my $file ('pod2htmd.tmp', 'pod2htmi.tmp') {
    if (-e $file) {
      unlink $file or warn "Warning: Could not remove file '$file'.\n$!\n";
    }
  }
  return $out_file;
}


sub _readme_man {
  my ($self, $in_file) = @_;
  require Pod::Man;
  my $out_file = 'README.1';
  my $parser = Pod::Man->new();
  $parser->parse_from_file($in_file, $out_file);
  return $out_file;
}


sub _all_from {
  my $self = shift;
  return unless $self->admin->{extensions};
  my ($metadata) = grep {
    ref($_) eq 'Module::Install::Metadata';
  } @{$self->admin->{extensions}};
  return unless $metadata;
  return $metadata->{values}{all_from} || '';
}

'Readme!';

__END__

=head1 NAME

Module::Install::ReadmeFromPod - A Module::Install extension to automatically convert POD to a README

=head1 SYNOPSIS

  # In Makefile.PL

  use inc::Module::Install;
  author 'Vestan Pants';
  license 'perl';
  readme_from 'lib/Some/Module.pm';
  readme_from 'lib/Some/Module.pm' => 'clean', 'htm';

A C<README> file will be generated from the POD of the indicated module file.

Note that the author will need to make sure
C<Module::Install::ReadmeFromPod> is installed
before running the C<Makefile.PL>.  (The extension will be bundled
into the user-side distribution).

=head1 DESCRIPTION

Module::Install::ReadmeFromPod is a L<Module::Install> extension that generates
a C<README> file automatically from an indicated file containing POD, whenever
the author runs C<Makefile.PL>. Several output formats are supported: plain-text,
html or manpage.

=head1 COMMANDS

This plugin adds the following Module::Install command:

=over

=item C<readme_from>

Does nothing on the user-side. On the author-side it will generate a C<README>
file.

  readme_from 'lib/Some/Module.pm';

If a second parameter is set to a true value then the C<README> will be removed at C<make distclean>.

  readme_from 'lib/Some/Module.pm' => 'clean';

A third parameter can be used to determine the format of the C<README> file.

  readme_from 'lib/Some/Module.pm' => 'clean', 'htm';

Valid formats are:

=over

=item txt

Produce a plain-text C<README> file using L<Pod::Text>. The 'txt' format is the
default.

=item htm

Produce an HTML C<README.htm> file using L<Pod::Html>.

=item man

Produce a C<README.1> manpage using L<Pod::Man>.

=back

If you use the C<all_from> command, C<readme_from> will default to that value.

  all_from 'lib/Some/Module.pm';
  readme_from;              # Create README from lib/Some/Module.pm
  readme_from '','clean';   # Put a empty string before 'clean'

=back

=head1 AUTHOR

Chris C<BinGOs> Williams

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<Module::Install>

L<Pod::Text>

L<Pod::Html>

L<Pod::Man>

=cut

