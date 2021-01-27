package Catalyst::View::Errors::JSON;

use Moose;
use JSON::MaybeXS;
use Catalyst::Utils::ContentNegotiation;
use Catalyst::Utils::ErrorMessages;

extends 'Catalyst::View';

has extra_encoder_args => (is=>'ro', required=>1, default => sub { +{} });

has encoder => (
  is => 'ro',
  init_arg => undef,
  required => 1,
  lazy => 1,
  default => sub { JSON::MaybeXS->new(utf8=>1, %{shift->extra_encoder_args}) },
);

has cn => (
  is => 'ro',
  init_arg => undef,
  required => 1, 
  default => sub { Catalyst::Utils::ContentNegotiation::content_negotiator },
);

has default_language => (is=>'ro', required=>1, default=>'en_US');

sub http_default {
  my ($self, $c, $code, %args) = @_;
  my $lang = $self->get_language($c);
  my $message_info = $self->finalize_message_info($c, $code, $lang, %args);

  my $json = $self->render_json($c, $message_info);
 
  $c->response->body($json);
  $c->response->content_type('application/json');
  $c->response->status($code);
}

sub get_language {
  my ($self, $c) = @_;
  if(my $lang = $c->request->header('Accept-Language')) {
    return $self->cn->choose_language([$self->available_languages($c)], $lang) || $self->default_language;
  }
  return $self->default_language;
}

sub available_languages {
  my ($self, $c) = @_;
  return my @lang_tags = Catalyst::Utils::ErrorMessages::available_languages;
}

sub finalize_message_info {
  my ($self, $c, $code, $lang, %args) = @_;
  my $message_info = $self->get_message_info($c, $lang, $code);
  return +{
    meta => {
      lang => $lang, 
      uri => delete($args{uri}), 
      %{$args{meta}||+{} },
    },
    errors => [
      {
        status => delete($args{code}),
        title => $message_info->{title},
        description => $message_info->{message},
      },
      @{$args{errors}||[] },
    ],
  };
}

sub get_message_info {
  my ($self, $c, $lang, $code) = @_;
  return my $message_info_hash = Catalyst::Utils::ErrorMessages::get_message_info($lang, $code);
}

sub render_json {
  my ($self, $c, $message_info) = @_;
  return $self->encoder->encode($message_info);
}

__PACKAGE__->meta->make_immutable;

=head1 TITLE

Catalyst::View::Errors::JSON - Standard HTTP Errors Responses in JSON

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO
 
L<CatalystX::Errors>.

=head1 AUTHOR
 
L<CatalystX::Errors>.
    
=head1 COPYRIGHT & LICENSE
 
L<CatalystX::Errors>.

=cut
