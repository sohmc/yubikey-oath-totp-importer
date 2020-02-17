# yubikey OATH importer

This script provides the ability to bulk-add OATH tokens onto a Yubikey.
Use cases could be creating a backup key, deploying multiple Yubikeys
for the same account, or just laziness and not wanting to import your
keys one by one.

## How to use:

```
$ import.bash somefile.txt
```

`somefile.txt` is a colon-delimited textfile that holds the
configuration of your OATH tokens.

The syntax is as follows:

```
account-name:issuer:secret-key:touch-true:options
```

* `account-name` (required): How you identify the token.  This will be used in the
  "NAME" portion of the
  [`ykman`](https://support.yubico.com/support/solutions/articles/15000012643-yubikey-manager-cli-ykman-user-guide#ykman_oath_add5an3x)
  command.
* `issuer`: Issuer of the credential.  This is an optional field.
* `secret-key` (required): The secret key for the token.  This is
  typically viewed when activating MFA.  You MUST have this value in
  order for you to import your key to your Yubikey.  If you do not have
  it, you will need to re-generate the secret.
* `touch-true`: Set to `t` if you want to require touching the yubikey to
  generate your code.  Default is to NOT require touching the yubikey
* `options`: other options to pass to the `ykman` command

Lines that start with `#` are silently ignored.  If an optional part of
the token doesn't apply (e.g. you don't need to set an issuer), you may
leave the field blank.

### Configuration example
```
# This example has all fields filled
John Doe:example.com:AA11 BBCC DDEE 22GG HHII JJKK 7788 1234:t:--algorithm SHA256

# This example does not require touch and uses default values
John Doe:facebook.com:aabb ccdd eeff gghh iijj kkll mmnn::

# This example doesn't have an issuer and uses default values
ssh-jdoe::FFFFFFFFFFFFFFFFFFFF::
```

Default values for importing keys is the same default values in place
for the `ykman oath` command:

* `--oath-type TOTP`
* `--digits 6`
* `--algorithm SHA1`
* `--period 30`

## Security Considerations

If you're using a Yubikey, you're already security conscience so kudos!
But may be wondering whether this script is safe to use.  That's a good
question.

This script does not use any other command besides Yubikey's `ykman` and
Linux internal command `read`.  So long as you trust those commands, you
can trust this script.  You can, and should, review the code before
running just to make sure I'm not doing anything hinky.

Second, you probably know this but you should not have the textfile with
all your secrets anywhere local on your computer or have it be
completely in the clear.  You should store it somewhere safe, preferably
offline.

Third, you should consider setting a password on your yubikey oath
application.  This can be set by using the following command:

```
$ ykman oath set-password
```


Finally, your Yubikey can break.  It's best to have a backup key.  And
that's where this script comes in REAL handy.


## License

This script is released using GPL 3.0.
