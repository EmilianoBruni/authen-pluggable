package Authen::Pluggable;

use Mojo::Base -base, -signatures;
use Mojo::Loader qw/load_class/;

has '_providers' => sub { return {} };
has 'log';

sub AUTOLOAD($s) {
    our $AUTOLOAD;
    $AUTOLOAD =~ s/.*:://;
    return $s->_providers->{$AUTOLOAD};
}

sub providers ( $s, @providers ) {
    my $bc = __PACKAGE__;
    foreach (@providers) {
        my $class = "${bc}::$_";
        unless ( my $e = load_class $class ) {
            $s->_providers->{$_} = $class->new(parent => $s);
        } else {
            ($s->log && $s->log->error($e)) || croak $e;
        }
    }
    return $s;
}

sub authen ( $s, $user, $pass ) {
    foreach my $provider (keys %{$s->_providers}) {
        my $uinfo = $s->_providers->{$provider}->authen($user, $pass);
        $uinfo && do {
            $uinfo->{provider} = $provider;
            return $uinfo;
        }
    }

    return undef
}

1;

__END__

# ABSTRACT: descrizione del modulo

=pod

=encoding UTF-8

=begin :badge

=begin html

<p>
    <a href="https://github.com/emilianobruni/authen-pluggable/actions/workflows/test.yml">
        <img alt="github workflow tests" src="https://github.com/emilianobruni/authen-pluggable/actions/workflows/test.yml/badge.svg">
    </a>
    <img alt="Top language: " src="https://img.shields.io/github/languages/top/emilianobruni/authen-pluggable">
    <img alt="github last commit" src="https://img.shields.io/github/last-commit/emilianobruni/authen-pluggable">
</p>
=end html

=end :badge

=head1 SYNOPSIS

  use Authen::Pluggable;

  my $module = Authen::Pluggable->new();


=head1 DESCRIPTION

Authen::Pluggable is a Perl module to authenticate users via pluggable modules

=head1 BUGS/CONTRIBUTING

Please report any bugs through the web interface at L<https://github.com/EmilianoBruni/micso-uauth/issues>

If you want to contribute changes or otherwise involve yourself in development, feel free to fork the Git repository from
L<https://github.com/EmilianoBruni/micso-uauth/>.

=head1 SUPPORT

You can find this documentation with the perldoc command too.

    perldoc Micso::UAuth

=cut
