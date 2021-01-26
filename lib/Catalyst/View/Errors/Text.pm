package Catalyst::View::Errors::Text;

use Moose;
use Text::Template;
use Catalyst::Utils::ContentNegotiation;
use Catalyst::Utils::ErrorMessages;

extends 'Catalyst::View';
with 'Catalyst::Component::ApplicationAttribute';

has template_engine_args => (
  is=>'ro',
  required=>1,
  lazy=>1,
  default=> sub {
    my $self = shift;
    my $template = $self->_application->config->{root}->file($self->template_name); 
    my $source = -e $template ? $template->slurp : $self->text($self->_application);
    return +{TYPE => 'STRING', SOURCE => $source};
  },
);

has template_name => (is=>'ro', required=>1, default=>'http_errors_text.tmpl');
has default_language => (is=>'ro', required=>1, default=>'en_US');

sub text {
  my ($self, $app) = @_;
  return q[{$code} {$title}:{$message}]."\n";
}

has template_engine => (
  is => 'ro',
  required => 1,
  init_arg => undef,
  lazy => 1,
  default => sub {
    my %args = %{shift->template_engine_args};
    my $engine = Text::Template->new(%args);
    $engine->compile;
    return $engine;
  }
);

has cn => (
  is => 'ro',
  init_arg => undef,
  required => 1, 
  default => sub { Catalyst::Utils::ContentNegotiation::content_negotiator },
);

sub http_default {
  my ($self, $c, $code, %args) = @_;
  my $lang = $self->get_language($c);
  my $message_info = $self->finalize_message_info($c, $code, $lang, %args);

  my $text = $self->render_template($c, $message_info);
 
  $c->response->body($text);
  $c->response->content_type('text/plain');
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
    %$message_info,
    lang => $lang,
    %args,
  };
}

sub get_message_info {
  my ($self, $c, $lang, $code) = @_;
  return my $message_info_hash = Catalyst::Utils::ErrorMessages::get_message_info($lang, $code);
}

sub render_template {
  my ($self, $c, $message_info) = @_;
  return my $text = $self->template_engine->fill_in(HASH => $message_info);
}

__PACKAGE__->meta->make_immutable;

=head1 TITLE

Catalyst::View::Errors::Text - Standard HTTP Errors Responses in Text

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO
 
L<CatalystX::Errors>.

=head1 AUTHOR
 
L<CatalystX::Errors>.
    
=head1 COPYRIGHT & LICENSE
 
L<CatalystX::Errors>.

=cut
