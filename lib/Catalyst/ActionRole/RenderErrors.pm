package Catalyst::ActionRole::RenderErrors;

use Moose::Role;
  
around 'execute', sub {
  my ($orig, $self, $controller, $c, @args) = @_;
  my $ret = $self->$orig($controller, $c, @args);

  return $ret if $c->debug;
  return $ret if $c->req->method eq 'HEAD';
  return $ret if defined $c->response->body;
  return $ret if $c->response->status =~ /^(?:204|3\d\d)$/;

  if(my @errors = @{$c->error}) {
    $c->clear_errors;
    $c->dispatch_error(500, errors=>\@errors);
  }

  return $ret;
};
 
1;

=head1 TITLE

Catalyst::ActionRole::RenderErrors - Automatically return an error page

=head1 SYNOPSIS

    package Example::Controller::Root;

    use Moose;
    use MooseX::MethodAttributes;

    extends 'Catalyst::Controller';

    sub root :Chained(/) PathPart('') CaptureArgs(0) {} 

      sub not_found :Chained(root) PathPart('') Args {
        my ($self, $c, @args) = @_;
        $c->detach_error(404);
      }

      sub die :Chained(root) PathPart(die) Args(0) {
        die "saefdsdfsfs";
      }

    sub end :Does(RenderErrors) { }

    __PACKAGE__->config(namespace=>'');
    __PACKAGE__->meta->make_immutable;
  
=head1 DESCRIPTION

Handles any uncaught errors (defined as "there's something in C<$c->errors>").  If in Debug mode
this just passes the errors down to the default L<Catalyst> debugging error response.  Otherwise
it converts to a Bad Request and dispatches an error page via C<$c->dispatch_error(500, errors=>\@errors)>.
This will give you a servicable http 500 error via content negotiation which you can customize as
desired (see L<CatalystX::Errors>).

Useful for API work since the default L<Catalyst> error page is in HTML.

=head1 SEE ALSO
 
L<CatalystX::Errors>.

=head1 AUTHOR
 
L<CatalystX::Errors>.
    
=head1 COPYRIGHT & LICENSE
 
L<CatalystX::Errors>.

=cut
