#!/usr/bin/perl
#use strict;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use WWW::Telegram::BotAPI;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
my $ya_token = "<Yandex_token>";
my $used_id = "<Telegram userid>";
my $token = "<Telegram_bot_token>";

get_sockets($ya_token);

sub get_sockets {
    my ($ya_token) = @_;
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://api.iot.yandex.net/v1.0/user/info";
# set custom HTTP request header fields
   my $req = HTTP::Request->new(GET => $server_endpoint);
   $req->header('content-type' => 'application/json');
   $req->header('Authorization' => "OAuth  $ya_token");
   my $state;
   my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    my $text = decode_json($message);
  #  $text2 = Dumper($text);

    foreach my $key (@{$text->{'devices'}}) {
  if ($key->{type} eq "devices.types.socket") {

      my $socket_name = $key->{"name"};
      my $socket_state = $key->{"capabilities"}[0]{"state"}{"value"};

      sent_telegram("выключено",$used_id,$socket_name, "1") unless $socket_state;

  }
}
    }
else {
    my $error_message = "Failed get state. \n HTTP GET error code: " .  $resp->code. "\n". "HTTP GET error message: ". $resp->message.  "\n" ;
    sent_telegram($error_message,$used_id,$socket_name, "2");
    return 2;
}
}

sub change_socket_state{

   my ($ya_token, $socket, $state) = @_;
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://api.iot.yandex.net/v1.0/devices/actions";
# set custom HTTP request header fields
   my $req = HTTP::Request->new(POST => $server_endpoint);
   $req->header('content-type' => 'application/json');
   $req->header('Authorization' => "OAuth  $ya_token");
    my $postdata = '{"devices": [{"id": "'.$socket_id.'",
                 "actions": [{"type": "devices.capabilities.on_off",
                 "state": {"instance": "on","value": '.$state.'}}]}]}';
$req->content ($postdata);
   my $state;
   my $resp = $ua->request($req);
    if ($resp->is_success) {
        print "succes \n";
 if (get_socket_state($ya_token, $socket_id)) {
    sent_telegram("poweredon",$used_id,$socket_name, "1");
}
 else {
    sent_telegram("Try to poweron mannualy ",$used_id,$socket_name, "1");
}
        return 0;
}
else {

    my $error_message = "Failed change state to $state \n HTTP GET error code: " .  $resp->code. "\n". "HTTP GET error message: ". $resp->message.  "\n" ;
        print $error_message;
    sent_telegram($error_message,$used_id,$socket_name, "2");
        return 2;
}
}

sub get_socket_state {
    my ($ya_token, $socket) = @_;
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://api.iot.yandex.net/v1.0/devices/$socket";
# set custom HTTP request header fields
   my $req = HTTP::Request->new(GET => $server_endpoint);
   $req->header('content-type' => 'application/json');
   $req->header('Authorization' => "OAuth  $ya_token");
   my $state;
   my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    my $text = decode_json($message);
  #  if  ($text-> {'state'} == 'offline') {
  #   sent_telegram("Device is offline.",$used_id,$socket_name, "2");
  #   exit 3;
  #  }
    return $text->{'capabilities'}[0]{'state'}{'value'};
}
else {
    my $error_message = "Failed get state. \n HTTP GET error code: " .  $resp->code. "\n". "HTTP GET error message: ". $resp->message.  "\n" ;
    sent_telegram($error_message,$used_id,$socket_name, "2");
    return 2;
}
}


sub sent_telegram{
    my ($message, $user, $socket_name, $flag) = @_;
    my $api = WWW::Telegram::BotAPI->new("token" => "$token");
    $api->getMe;
    if ($flag == '1') {
    $message ="$socket_name статус  $message";
    }
    else {
       $message = "Ошибка для $socket_name : \n $message ";
          }
    $api->sendMessage ({
    chat_id => "$user",
    text    => "$message"
    }) ;
}
