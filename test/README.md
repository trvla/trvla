Script get for Yandex socket state, and if it poweredoff, try to poweron in.   <br />
If socket is offline it will sent offline message.  <br />
Needed telegram bot token, Yandex OAuth token with smart home permissions, socket id  <br />

$socket_name - name for telegram messages   <br />
$socket_id - Socket id from Yandex smart home   <br />
$ya_token - token from Yandex OAuth  <br />
$used_id - telegram userid for recieve messages  <br />
$token -  telegram bot token  <br />
 <br />
 Tested with perl 5.32. <br />
 Needed :  <br />
 LWP::UserAgent <br />
 JSON <br />
 Data::Dumper <br />
 WWW::Telegram::BotAPI <br />
