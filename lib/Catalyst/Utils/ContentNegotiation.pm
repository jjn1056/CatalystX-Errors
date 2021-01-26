package Catalyst::Utils::ContentNegotiation;

use HTTP::Headers::ActionPack;

sub content_negotiator { our $cn ||= HTTP::Headers::ActionPack->new->get_content_negotiator }

1;
