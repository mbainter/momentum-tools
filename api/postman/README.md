h1. -- WARNING --

Please note that this is a quickly churned out set of queries that I setup to
do some testing.  It is not guaranteed to be correct, or even the best way to 
implement a given query.  It is only a rough way to do some simple testing for
the purpose of verifying things are operational.

Everything here should work, and should not break anything, but no guarantees
are expressed or implied. 

h1. Contributing

If you have made improvements and would like to submit a pull request, please 
make sure it is formatted well first.  You can do this using the rather useful
[jq](http://stedolan.github.io/jq/) tool.  If you're a fellow vim user, you 
can add this to your vimrc to make reformatting even more handy:

```vimscript
if has("autocmd")
    autocmd FileType json nnoremap <buffer> <leader>gq :%!jq --unbuffered -M '.'<CR>
    autocmd FileType json vnoremap <buffer> <leader>gq :!jq --unbuffered -M '.'<CR>
endif
```

h1. Postman Connection for Momentum 4.x REST API

This is a JSON file that can be imported into Chrome's "Postman" plugin as a 
collection to more easily interact with the API during development and testing.

You can install the plugin here: 
https://chrome.google.com/webstore/detail/postman-rest-client/

Then import it from the appropriate JSON file depending on the version of the 
code and the version of the API you need.  

h1. Configuring the Collection

h2. Global Variables

Within Postman, you'll need to configure the following global variables:
*PMG_MY_EMAIL* - This is a test email address, usually your own, which would be
global across any instances you might be trying to test.

*PMG_MY_NAME* - Your name, for the friendly name in the address field.

*PMG_MY_TZ* - Your local time zone, as used by the API.

h2. Environment Variables

For each environment you want to test, you'll need to configure that environment 
within postman using the following variables:

*PM_API_KEY* - This is the API key you configured within the UI with the permission
to interact.  Currently this postman configuration assumes a single API key with all
rights allowed.

*PM_API_URL* - This is the base URL to the API, which should look something like:
http://host.domain.ext/api/v1/

*PM_RL_ID* - This is the Recipient List ID used to manage the test recipient list
across queries.

*PM_CAMPAIGN_ID* - This is a common campaign ID to use across all the different 
API calls that need one.  Keeping this common makes it easier to identify when 
doing reporting.

*PM_TEMPLATE_ID* - This is the template_id that will be used for generating a 
template, and of course using that template in other API calls where it is 
required.

*PM_RETURN_PATH* - This variable defines the envelope from address used when 
injecting the message.

*PM_FRIENDLY_FROM* - This variable defines the friendly from address that will
be used in the message headers.

*PM_CLIENT* - This variable is used to test variable substitution in the headers 
and message content when doing injection.  It can contain any value.

*PM_BINDING* - This is used to do variable substitution in the header.  The 
assumption is you have some form of binding logic based on an X-Binding header. 
If you do, then you can do tests to bind to specific bindings or groups based 
on what you substitute here.  Otherwise this does nothing, and any value will
do.

