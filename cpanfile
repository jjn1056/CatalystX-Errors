requires 'Moose';
requires 'MRO::Compat';
requires 'HTTP::Headers::ActionPack';
requires 'Catalyst::Utils';
requires 'Text::Template';
requires 'JSON::MaybeXS';

on test => sub {
  requires 'Test::Most' => '0.34';
  requires 'Catalyst';
};
