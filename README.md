yahoo-groups-moderator-reports
==============================

Yahoo Groups moderator tools are woefully nonexistant! This is unfortunate for those of us stuck moderating them.

So at one point (mainly, now) I got stuck being the approval authority for a particular Yahoo Group. Turns out Yahoo really doesn't provide any feedback or info about moderation statistics.

Things I wanted to know:
* who's actively moderating
* how many messages were approved
* time of approval and time to approval


How it works:
==============================

Emails to Yahoo Groups that require all emails to be moderated are first sent to all group moderators. A reply to that email from any one moderator releases the original email to the rest of the group. Generally, if you group name is GROUP_NAME, moderation emails come from GROUP_NAME@yahoogroups.com, and NOT from the senders' original email. Furthermore, all group emails sent out have a prefix of[GROUP_NAME] in the subject line. The re-mailer address always seems to be 'returns.groups.yahoo.com'.

Rather than scraping Yahoo Groups directly (which is slow/painful), I decided to extract all emails from your own gmail mailbox. Off course, this implies that you're using gmail/gmail-backed inbox. This isn't a problem for me but feel free to complain about it!

So I login to gmail and pull down all emails that came from 'returns.groups.yahoo.com', within the specified time interval (defaults to going back 1 week), mailed to GROUP_NAME.yahoogroups.com.

Yahoo Groups claimed at one point that moderation status is secret. Which is horseshit, there's a field called 'X-eGroups-Approved-By' which gives the email of the moderator that approved that particular email. This has the unfortunate side-effect of making all Yahoo Group moderation public. Any emails you personally moderate reveal your email address.

After that, its just collecting statistics about how long it took for each email to get moderated, how many moderators are active and what time they moderate.


Required Packages:
==============================

* gmail
* tzinfo
* yaml
* gruff (for pretty graphics only, otherwise you get sad, ugly yaml)


How to use it:
==============================

Assuming all packages are installed, running
    ruby gmail.rb username password group_name
will login to the specified gmail account, retrieve all messages received within the last 7 days and spit out a yaml

You can also optionally specify start_date and end_date, in that order, in this format yyyy-mm-dd.

Next, you want to run
    ruby Gen_YahooGroup_Reports filename.yaml
This will generate a text file report with your statistics, along with pretty graphics, if you have gruff package installed. The parameter filename.yaml is the output of gmail.rb.


Future work:
==============================

None planned.

If someone actually wants to use it and needs moar graphs/stats or just wants an adaptor for non-gmail, let me know and I'd be happy to help.