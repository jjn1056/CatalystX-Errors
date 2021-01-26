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
 
1
